#!/usr/bin/env python3
"""asc-upload-shots.py - CLI for the screenshot half of the toolkit (the studio does the same in a browser).

Dry run by default: prints what is on App Store Connect and what would be uploaded.
    asc-upload-shots.py            # read-only plan
    asc-upload-shots.py --apply    # upload the missing images, in file order
    asc-upload-shots.py --apply --replace   # delete what is there first, then upload everything

Reads ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_PATH like asc-sync.py. Images come from
<screenshots_dir>/<device>/<lang>/NN-name.png (see _config.json).
"""
from __future__ import annotations

import argparse, importlib.util, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent


def _load(name: str, filename: str):
    spec = importlib.util.spec_from_file_location(name, HERE / filename)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


S = _load("asc_sync", "asc-sync.py")
M = _load("asc_media", "asc-media.py")
SHOTS = S.ROOT / S._paths()["screenshots_dir"]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="upload for real (default: read-only plan)")
    ap.add_argument("--replace", action="store_true", help="with --apply: delete existing screenshots of each set first")
    args = ap.parse_args()

    sync = S.load_config()
    cl = S.Client(S.token, apply=False)
    apps = cl.get_all(f"/v1/apps?filter[bundleId]={sync['bundle_id']}&limit=10")
    if not apps:
        sys.exit(f"no app found for bundle id {sync['bundle_id']} on this API key")
    app_id = apps[0]["id"]
    versions = [v for v in cl.get_all(
        f"/v1/apps/{app_id}/appStoreVersions?filter[platform]={sync.get('platform', 'IOS')}&limit=20")
        if v["attributes"].get("appStoreState") in S.EDITABLE]
    if not versions:
        sys.exit("no editable App Store version found")
    version = versions[0]["id"]
    print(f"app {sync['bundle_id']} -> {app_id}, version {versions[0]['attributes'].get('versionString')}\n")

    plan = M.plan(cl, version, SHOTS, sync["locales"])
    for w in plan["warnings"]:
        print(f"  ! {w}")
    for r in plan["rows"]:
        print(f"{r['device']}/{r['locale']} ({r['displayType']}): {len(r['files'])} local, "
              f"{r['existing']} on App Store Connect, {len(r['missing'])} to upload"
              + ("  [BLOCKED: fix the warnings]" if r["blocked"] else ""))
        for name in r["missing"]:
            print(f"    + {name}")
    if not args.apply:
        print(f"\n{plan['total']} image(s) would be uploaded. Re-run with --apply to write them.")
        return 0

    cl.apply = True
    errors: list[str] = []
    for r in plan["rows"]:
        if r["blocked"]:
            continue
        tag = f"{r['device']}/{r['locale']}"
        set_id = r["setId"] or M.find_or_make_set(cl, r["locId"], r["displayType"], apply=True)
        if args.replace:
            for old in M.existing(cl, set_id):
                cl._call("DELETE", f"/v1/appScreenshots/{old['id']}")
        have = {s["attributes"].get("fileName") for s in M.existing(cl, set_id)}
        for path in r["paths"]:
            name = pathlib.Path(path).name
            if name in have:
                continue
            print(f"  uploading {tag} {name} ...", flush=True)
            try:
                M.upload_one(cl, set_id, pathlib.Path(path))
            except SystemExit as e:
                errors.append(f"{tag} {name}: {e}")
            except Exception as e:  # keep going: one refused image must not stop the rest
                errors.append(f"{tag} {name}: {type(e).__name__}: {e}")
        order = [pathlib.Path(q).name for q in r["paths"]]
        live = {s["attributes"].get("fileName"): s["id"] for s in M.existing(cl, set_id)}
        final = [live[n] for n in order if n in live]
        if len(final) > 1:
            try:
                M.reorder(cl, set_id, final)
            except Exception as e:
                errors.append(f"{tag} reorder: {e}")

    left = M.plan(cl, version, SHOTS, sync["locales"])
    print()
    for r in left["rows"]:
        print(f"{r['device']}/{r['locale']}: {r['existing']} on App Store Connect, {len(r['missing'])} missing")
    for e in errors:
        print(f"  ! {e}")
    return 1 if errors or left["total"] else 0


if __name__ == "__main__":
    sys.exit(main())
