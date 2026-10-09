#!/usr/bin/env python3
"""asc-sync.py - push the metadata in this repo to App Store Connect.

    appstore/metadata-json/*.json   ->  app name, subtitle, privacy URL,
                                        description, keywords, promo text, what's new
    the project's *.storekit        ->  subscription + group display names and descriptions

Two sources, one command, no retyping. Fastlane deliver covers only the first of
those two - it has no concept of subscription localizations - which is why this
talks to the App Store Connect API directly instead.

DRY RUN IS THE DEFAULT. Without --apply the script only reads, and prints exactly
what would change. Nothing is written to App Store Connect until you pass --apply.

Credentials (an App Store Connect API key, Users and Access > Integrations):
    export ASC_KEY_ID=XXXXXXXXXX
    export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    export ASC_KEY_PATH=~/.appstoreconnect/AuthKey_XXXXXXXXXX.p8
The .p8 is read once to sign a 15-minute token. It is never logged, copied or sent
anywhere except as that signature. Keep it outside the repo and outside Dropbox.

Usage:
    tools/appstore/asc-sync.py                  # dry run, everything
    tools/appstore/asc-sync.py --only iap       # dry run, subscriptions only
    tools/appstore/asc-sync.py --apply          # write it
    tools/appstore/asc-sync.py --apply --only listing --locale vi --locale ja

Needs only the standard library, plus something to sign the token with: the
`cryptography` package when it is installed, otherwise the `openssl` command that
macOS already ships. No fastlane, no ruby, no extra gems.
"""
from __future__ import annotations

import argparse, base64, http.client, json, os, pathlib, re, shutil, subprocess, sys, time
import urllib.error, urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[2]
API  = "https://api.appstoreconnect.apple.com"

# Layout. Overridable per project from _config.json's "sync.paths", so this folder
# can be copied into another repo without editing any code.
DEFAULTS = {"metadata_dir": "appstore/metadata-json",
            "screenshots_dir": "appstore/output",
            "storekit": None}          # None = find the single *.storekit in the repo


def config_file() -> pathlib.Path:
    """Locate _config.json without assuming where the metadata lives.

    `metadata_dir` is itself configured inside that file, so deriving the search
    location from it would mean a project that moves the folder could never be found.
    The conventional path is tried first, then the repo is searched for a _config.json
    that actually carries this schema.

    A project that keeps one folder per release (AppStore/1.0.0/…, AppStore/1.0.1/…)
    has one such file per release, and the newest is the one being prepared - plain
    path order would keep picking 1.0.0 forever."""
    default = ROOT / DEFAULTS["metadata_dir"] / "_config.json"
    if default.is_file():
        return default
    found = []
    for q in sorted(ROOT.rglob("_config.json")):
        if any(part in {"node_modules", ".git", ".build"} for part in q.parts):
            continue
        try:
            doc = json.loads(q.read_text(encoding="utf-8"))
        except Exception:
            continue
        if isinstance(doc, dict) and ("sync" in doc or "languages" in doc):
            found.append(q)
    if found:
        # max() keeps the first of equals, so unversioned layouts pick as before.
        return max(found, key=_release)
    sys.exit(f"No metadata _config.json found under {ROOT}. Copy "
             f"tools/appstore/_config.template.json into your metadata folder.")


def _release(path: pathlib.Path) -> tuple[int, ...]:
    """The version a path is filed under: AppStore/1.0.1/metadata-json -> (1, 0, 1).
    () when none of its folders is named like a version."""
    for part in reversed(path.relative_to(ROOT).parts):
        if re.fullmatch(r"\d+(?:\.\d+)+", part):
            return tuple(int(n) for n in part.split("."))
    return ()


def meta_dir() -> pathlib.Path:
    return config_file().parent


def _paths() -> dict:
    """The three project paths, preferring _config.json over the defaults."""
    try:
        over = json.loads(config_file().read_text(encoding="utf-8")).get("sync", {}).get("paths") or {}
    except SystemExit:
        over = {}
    return {**DEFAULTS, **over}


def storekit_path() -> pathlib.Path:
    """The .storekit file, from config or by finding the only one in the repo.

    Auto-detection keeps this folder drop-in portable: a project with one StoreKit
    config needs no setup, and a project with several is told to name the one it
    means rather than having a guess made for it."""
    named = _paths()["storekit"]
    if named:
        return ROOT / named
    found = [q for q in ROOT.rglob("*.storekit") if ".build" not in q.parts]
    if len(found) == 1:
        return found[0]
    if not found:
        sys.exit("No .storekit file found. Set sync.paths.storekit in _config.json, "
                 "or skip subscriptions with --only listing.")
    rel = ", ".join(str(q.relative_to(ROOT)) for q in sorted(found)[:6])
    sys.exit(f"{len(found)} .storekit files found ({rel}). "
             f"Name the right one in _config.json under sync.paths.storekit.")

# An App Store version in any other state is read-only; writing to it is rejected.
EDITABLE = {
    "PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED",
    "INVALID_BINARY", "WAITING_FOR_REVIEW", "DEVELOPER_REMOVED_FROM_SALE",
}
LISTING_FIELDS = ("description", "keywords", "promotionalText", "whatsNew",
                  "marketingUrl", "supportUrl")


def listing_fields(cl: "Client", app_id: str) -> tuple:
    """LISTING_FIELDS, minus `whatsNew` on a first release.

    "What's New in This Version" only exists once an app has shipped something to be
    new against. On a 1.0 App Store Connect does not merely hide the field, it refuses
    the write - "Attribute 'whatsNew' cannot be edited at this time" - and that one
    rejection used to take the other thirteen locales down with it. A single version
    record means nothing has shipped yet, so the field is dropped rather than sent.
    The text stays in the JSON, ready for 1.0.1."""
    versions = cl.get_all(f"/v1/apps/{app_id}/appStoreVersions?limit=200")
    if len(versions) <= 1:
        print(f"  {C['dim']}first release: 'whatsNew' skipped "
              f"(App Store Connect has no such field until 1.0 ships){C['off']}")
        return tuple(f for f in LISTING_FIELDS if f != "whatsNew")
    return LISTING_FIELDS
INFO_FIELDS    = ("name", "subtitle", "privacyPolicyUrl")

C = {"dim": "\033[2m", "red": "\033[31m", "grn": "\033[32m", "yel": "\033[33m", "off": "\033[0m"}
if not sys.stdout.isatty():
    C = dict.fromkeys(C, "")


# ── auth ────────────────────────────────────────────────────────────────────────
def _b64(raw: bytes) -> bytes:
    return base64.urlsafe_b64encode(raw).rstrip(b"=")


def _der_to_rs(der: bytes) -> tuple[int, int]:
    """(r, s) out of the DER `SEQUENCE { INTEGER r, INTEGER s }` openssl signs with."""
    def tlv(buf: bytes, at: int, tag: int) -> tuple[bytes, int]:
        if buf[at] != tag:
            raise ValueError("openssl did not return an ECDSA signature")
        size, at = buf[at + 1], at + 2
        if size & 0x80:                          # long form: the length's own length
            n = size & 0x7F
            size, at = int.from_bytes(buf[at:at + n], "big"), at + n
        return buf[at:at + size], at + size
    seq, _ = tlv(der, 0, 0x30)
    r, at = tlv(seq, 0, 0x02)
    s, _ = tlv(seq, at, 0x02)
    return int.from_bytes(r, "big"), int.from_bytes(s, "big")


def _es256(key_file: pathlib.Path, data: bytes) -> bytes:
    """The raw r||s signature a JWT carries.

    `cryptography` signs when it is installed. A stock macOS python3 does not have
    it, and pip-installing a crypto library just to mint a token is a poor first
    step, so the `openssl` the OS already ships is the fallback. Either way the key
    file is read on this machine only."""
    try:
        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.asymmetric import ec, utils
    except ImportError:
        exe = shutil.which("openssl")
        if not exe:
            sys.exit("Signing needs the `cryptography` package "
                     "(python3 -m pip install --user cryptography) or the `openssl` command.")
        run = subprocess.run([exe, "dgst", "-sha256", "-sign", str(key_file)],
                             input=data, capture_output=True)
        if run.returncode != 0:
            sys.exit(f"openssl could not sign with {key_file.name}: "
                     f"{run.stderr.decode('utf-8', 'replace').strip()}")
        r, s = _der_to_rs(run.stdout)
    else:
        key = serialization.load_pem_private_key(key_file.read_bytes(), password=None)
        r, s = utils.decode_dss_signature(key.sign(data, ec.ECDSA(hashes.SHA256())))
    return r.to_bytes(32, "big") + s.to_bytes(32, "big")


def token() -> str:
    """ES256 JWT, signed locally. The private key never leaves this machine."""
    kid = os.environ.get("ASC_KEY_ID")
    iss = os.environ.get("ASC_ISSUER_ID")
    pth = os.environ.get("ASC_KEY_PATH")
    missing = [n for n, v in (("ASC_KEY_ID", kid), ("ASC_ISSUER_ID", iss), ("ASC_KEY_PATH", pth)) if not v]
    if missing:
        sys.exit(f"missing environment variable(s): {', '.join(missing)}\n"
                 f"Create a key at App Store Connect > Users and Access > Integrations, "
                 f"then export the three values (see the header of this file).")
    key_file = pathlib.Path(pth).expanduser()
    if not key_file.is_file():
        sys.exit(f"ASC_KEY_PATH does not point at a file: {key_file}")

    now = int(time.time())
    head = _b64(json.dumps({"alg": "ES256", "kid": kid, "typ": "JWT"}).encode())
    body = _b64(json.dumps({"iss": iss, "iat": now, "exp": now + 900,
                            "aud": "appstoreconnect-v1"}).encode())
    signing_input = head + b"." + body
    return (signing_input + b"." + _b64(_es256(key_file, signing_input))).decode()


# ── transport ───────────────────────────────────────────────────────────────────
class Client:
    """Talks to App Store Connect, and keeps its own token alive.

    Apple caps a token at 20 minutes and this one is signed for 15. A single sync of
    14 locales is quick, but a 252-image screenshot upload is not: minting the token
    once at startup meant it expired mid-run and every request after that failed with
    a 401 the caller could do nothing about. Signing is local and costs microseconds,
    so the token is re-minted whenever it is close to stale, and once more if a 401
    still slips through (clock skew, a request in flight across the boundary)."""

    REFRESH_AFTER = 780          # 13 min - comfortably inside the 15 min lifetime
    RETRY_ON = {429, 500, 502, 503, 504}

    def __init__(self, jwt, apply: bool):
        # `jwt` is normally the minting function; a plain string is accepted so tests
        # can pin a fixed token.
        self._mint = jwt if callable(jwt) else (lambda: jwt)
        self._jwt: str | None = None
        self._minted = 0.0
        self.apply = apply
        self.writes = 0

    @property
    def jwt(self) -> str:
        if self._jwt is None or time.time() - self._minted > self.REFRESH_AFTER:
            self._jwt = self._mint()
            self._minted = time.time()
        return self._jwt

    # App Store Connect returns a sporadic 500 on perfectly valid reads, and 429 when
    # a sync of 14 locales moves faster than it likes. Both clear on their own, so a
    # short backoff is the difference between a working run and a scary false alarm.
    def _call(self, method: str, path: str, payload=None, attempt: int = 1):
        url = path if path.startswith("http") else API + path
        data = json.dumps(payload).encode() if payload is not None else None
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", f"Bearer {self.jwt}")
        if data:
            req.add_header("Content-Type", "application/json")
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                raw = r.read()
                return json.loads(raw) if raw else {}
        except urllib.error.HTTPError as e:
            if e.code == 401 and attempt == 1:
                self._jwt = None                      # force a fresh signature, once
                return self._call(method, path, payload, attempt + 1)
            if e.code in self.RETRY_ON and attempt <= 4:
                time.sleep(1.5 * attempt)
                return self._call(method, path, payload, attempt + 1)
            detail = e.read().decode("utf-8", "replace")
            try:
                errs = json.loads(detail).get("errors", [])
                detail = "; ".join(f"{x.get('title')}: {x.get('detail')}" for x in errs) or detail
            except Exception:
                pass
            sys.exit(f"{C['red']}HTTP {e.code} on {method} {path}{C['off']}\n  {detail}")
        except (urllib.error.URLError, http.client.HTTPException, OSError) as e:
            # RemoteDisconnected is an HTTPException, NOT a URLError - urllib does not
            # wrap what h.getresponse() raises - so catching URLError alone let a
            # dropped keep-alive kill a run that a one-second wait would have saved.
            if attempt <= 5:
                time.sleep(min(1.5 * attempt, 8))
                return self._call(method, path, payload, attempt + 1)
            sys.exit(f"{C['red']}network error on {method} {path}{C['off']}\n  "
                     f"{type(e).__name__}: {e}")

    def get_all(self, path: str) -> list:
        """Follow `links.next` so a >200 collection is never silently truncated."""
        out, page = [], path
        while page:
            doc = self._call("GET", page)
            out += doc.get("data", [])
            page = doc.get("links", {}).get("next")
        return out

    def write(self, method: str, path: str, payload: dict):
        if not self.apply:
            return None
        self.writes += 1
        return self._call(method, path, payload)


# ── sources ─────────────────────────────────────────────────────────────────────
def load_config() -> dict:
    cfg = json.loads(config_file().read_text(encoding="utf-8"))
    if "sync" not in cfg:
        sys.exit("_config.json has no \"sync\" block (bundle_id, locales, urls).")
    return cfg["sync"]


def desired_listing(sync: dict) -> dict:
    """{asc_locale: {field: value}} for both appInfo and version localizations."""
    out = {}
    for code, spec in sync["locales"].items():
        d = json.loads((meta_dir() / f"{code}.json").read_text(encoding="utf-8"))
        out[spec["asc"]] = {
            "name": d["name"], "subtitle": d["subtitle"],
            "privacyPolicyUrl": spec["privacy_url"],
            "description": d["description"], "keywords": d["keywords"],
            "promotionalText": d["promotional_text"],
            "whatsNew": d.get("whats_new") or "",
            "marketingUrl": sync.get("marketing_url") or None,
            "supportUrl": sync.get("support_url") or None,
        }
    return out


def desired_iap(sync: dict) -> tuple[dict, dict]:
    """({asc_locale: group_name}, {productId: {asc_locale: {name, description}}})."""
    sk = json.loads(storekit_path().read_text(encoding="utf-8"))
    if not sk.get("subscriptionGroups"):
        # An app that sells only one-time purchases has nothing for this half to do,
        # and "Listing + IAP" must not fall over on it.
        return {}, {}
    grp = sk["subscriptionGroups"][0]
    m = sync["storekit_locales"]
    group = {m[l["locale"]]: l["displayName"] for l in grp["localizations"] if l["locale"] in m}
    subs = {}
    for s in grp["subscriptions"]:
        subs[s["productID"]] = {
            m[l["locale"]]: {"name": l["displayName"], "description": l["description"]}
            for l in s["localizations"] if l["locale"] in m
        }
    return group, subs


# ── reconcile ───────────────────────────────────────────────────────────────────
def plan_changes(existing: list, want: dict, fields: tuple) -> list[dict]:
    """Structured diff. The single source of truth for "what would change" - the CLI
    prints it, the web studio serializes it, so the two can never disagree."""
    by_locale = {r["attributes"]["locale"]: r for r in existing}
    plan = []
    for locale, values in sorted(want.items()):
        values = {k: v for k, v in values.items() if k in fields and v is not None}
        row = by_locale.get(locale)
        if row is None:
            plan.append({"action": "create", "locale": locale, "id": None,
                         "fields": {k: {"old": None, "new": v} for k, v in values.items()}})
            continue
        diff = {k: {"old": row["attributes"].get(k) or "", "new": v}
                for k, v in values.items() if (row["attributes"].get(k) or "") != v}
        if diff:
            plan.append({"action": "update", "locale": locale, "id": row["id"], "fields": diff})
        else:
            plan.append({"action": "same", "locale": locale, "id": row["id"], "fields": {}})
    return plan


def apply_plan(cl: "Client", kind: str, plan: list, create_path: str,
               create_rel: dict) -> list[str]:
    """Write every step, and keep going when one is refused.

    Each locale is an independent write. Letting the first rejection raise meant a
    single bad field left the listing half-written, which is worse than either
    outcome - so failures are collected and reported, and the rest still land."""
    errors = []
    for step in plan:
        try:
            if step["action"] == "create":
                cl.write("POST", create_path, {"data": {
                    "type": kind,
                    "attributes": {**{k: v["new"] for k, v in step["fields"].items()},
                                   "locale": step["locale"]},
                    "relationships": create_rel}})
            elif step["action"] == "update":
                cl.write("PATCH", f"/v1/{kind}/{step['id']}", {"data": {
                    "type": kind, "id": step["id"],
                    "attributes": {k: v["new"] for k, v in step["fields"].items()}}})
        except SystemExit as e:
            errors.append(f"{step['locale']}: {e}")
        except Exception as e:
            errors.append(f"{step['locale']}: {type(e).__name__}: {e}")
    return errors


def reconcile(cl: Client, kind: str, existing: list, want: dict, fields: tuple,
              create_path: str, create_rel: dict, label: str) -> tuple[int, int]:
    """PATCH what differs, POST what is missing. Returns (changed, created)."""
    plan = plan_changes(existing, want, fields)
    changed = created = 0
    for step in plan:
        if step["action"] == "same":
            continue
        if step["action"] == "create":
            created += 1
            print(f"  {C['grn']}+ create{C['off']} {label} {step['locale']}  "
                  + ", ".join(f"{k}={len(str(v['new']))}c" for k, v in step["fields"].items()))
            continue
        changed += 1
        print(f"  {C['yel']}~ update{C['off']} {label} {step['locale']}  "
              + ", ".join(sorted(step["fields"])))
        for k, v in sorted(step["fields"].items()):
            was = (v["old"] or "").replace("\n", "\\n")
            now = v["new"].replace("\n", "\\n")
            print(f"      {C['dim']}{k}: {was[:58]!r}{C['off']}")
            print(f"      {C['dim']}{' ' * len(k)}  -> {now[:58]!r}{C['off']}")
    for err in apply_plan(cl, kind, plan, create_path, create_rel):
        print(f"  {C['red']}! {err}{C['off']}")
    return changed, created


def main() -> int:
    ap = argparse.ArgumentParser(description="Sync repo metadata to App Store Connect.")
    ap.add_argument("--apply", action="store_true",
                    help="actually write. Without it the script only reads and reports.")
    ap.add_argument("--only", choices=("listing", "iap", "all"), default="all")
    ap.add_argument("--locale", action="append", default=[],
                    help="restrict to these repo locale codes (repeatable), e.g. --locale vi")
    args = ap.parse_args()

    sync = load_config()
    if args.locale:
        keep = {sync["locales"][c]["asc"] for c in args.locale if c in sync["locales"]}
        unknown = [c for c in args.locale if c not in sync["locales"]]
        if unknown:
            sys.exit(f"unknown locale code(s): {', '.join(unknown)}")
    else:
        keep = None

    cl = Client(token, args.apply)
    mode = f"{C['red']}APPLY{C['off']}" if args.apply else f"{C['grn']}DRY RUN{C['off']} (nothing is written)"
    print(f"App Store Connect sync - {mode}\n")

    apps = cl.get_all(f"/v1/apps?filter[bundleId]={sync['bundle_id']}&limit=10")
    if not apps:
        sys.exit(f"no app found for bundle id {sync['bundle_id']} on this API key")
    app_id = apps[0]["id"]
    print(f"app {sync['bundle_id']} -> {app_id}")

    total = 0
    if args.only in ("listing", "all"):
        want = desired_listing(sync)
        if keep:
            want = {k: v for k, v in want.items() if k in keep}

        infos = [i for i in cl.get_all(f"/v1/apps/{app_id}/appInfos?limit=50")
                 if i["attributes"].get("appStoreState") in EDITABLE]
        if not infos:
            sys.exit("no editable appInfo - is there a version in Prepare for Submission?")
        info_id = infos[0]["id"]
        print(f"\nApp Information ({infos[0]['attributes']['appStoreState']})")
        c, n = reconcile(
            cl, "appInfoLocalizations",
            cl.get_all(f"/v1/appInfos/{info_id}/appInfoLocalizations?limit=200"),
            want, INFO_FIELDS, "/v1/appInfoLocalizations",
            {"appInfo": {"data": {"type": "appInfos", "id": info_id}}}, "name/subtitle")
        total += c + n

        vers = [v for v in cl.get_all(
                    f"/v1/apps/{app_id}/appStoreVersions?filter[platform]={sync.get('platform','IOS')}&limit=20")
                if v["attributes"].get("appStoreState") in EDITABLE]
        if not vers:
            sys.exit("no editable App Store version found")
        ver = vers[0]
        print(f"\nVersion {ver['attributes'].get('versionString')} ({ver['attributes']['appStoreState']})")
        c, n = reconcile(
            cl, "appStoreVersionLocalizations",
            cl.get_all(f"/v1/appStoreVersions/{ver['id']}/appStoreVersionLocalizations?limit=200"),
            want, listing_fields(cl, app_id), "/v1/appStoreVersionLocalizations",
            {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": ver["id"]}}}, "listing")
        total += c + n

    if args.only in ("iap", "all"):
        group_want, sub_want = desired_iap(sync)
        if keep:
            group_want = {k: v for k, v in group_want.items() if k in keep}
            sub_want = {p: {k: v for k, v in d.items() if k in keep} for p, d in sub_want.items()}

        groups = cl.get_all(f"/v1/apps/{app_id}/subscriptionGroups?limit=50")
        if not groups:
            # Not an error. The listing half may be all the caller wanted, and the
            # products simply may not exist on App Store Connect yet.
            print(f"\n{C['yel']}No subscription group on this app yet.{C['off']} Create the group and "
                  f"the two products on App Store Connect, then re-run with --only iap.")
        else:
            gid = groups[0]["id"]
            print(f"\nSubscription group {groups[0]['attributes'].get('referenceName')}")
            c, n = reconcile(
                cl, "subscriptionGroupLocalizations",
                cl.get_all(f"/v1/subscriptionGroups/{gid}/subscriptionGroupLocalizations?limit=200"),
                {k: {"name": v} for k, v in group_want.items()}, ("name",),
                "/v1/subscriptionGroupLocalizations",
                {"subscriptionGroup": {"data": {"type": "subscriptionGroups", "id": gid}}}, "group name")
            total += c + n

            live = {s["attributes"]["productId"]: s
                    for s in cl.get_all(f"/v1/subscriptionGroups/{gid}/subscriptions?limit=200")}
            for pid, want_locales in sub_want.items():
                s = live.get(pid)
                if s is None:
                    print(f"  {C['red']}! {pid} is in {storekit_path().name} but not in "
                          f"App Store Connect{C['off']}")
                    continue
                print(f"\nSubscription {pid}")
                c, n = reconcile(
                    cl, "subscriptionLocalizations",
                    cl.get_all(f"/v1/subscriptions/{s['id']}/subscriptionLocalizations?limit=200"),
                    want_locales, ("name", "description"), "/v1/subscriptionLocalizations",
                    {"subscription": {"data": {"type": "subscriptions", "id": s["id"]}}}, "IAP")
                total += c + n

    print()
    if total == 0:
        print(f"{C['grn']}Everything already matches the repo.{C['off']}")
    elif args.apply:
        print(f"{C['grn']}Applied {cl.writes} write(s).{C['off']}")
    else:
        print(f"{total} field group(s) differ. Re-run with {C['red']}--apply{C['off']} to write them.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
