#!/usr/bin/env python3
"""asc-studio.py - a local web console for pushing this repo's metadata to App Store Connect.

    tools/appstore/asc-studio.py           then open the URL it prints

Pick the app by bundle id, pick or create the version, read every field of all 14
locales side by side with the values already live, then publish. Same data and the
same diff engine as asc-sync.py (it imports them), with eyes on it before the write.

WHY LOCAL AND NOT A HOSTED PAGE
The .p8 signing key has to be read from disk and the repo has to be read from disk,
so the process doing that must run on your machine. The browser is only a front end:
it never receives the key, the JWT, or anything derived from them.

SAFETY
  * binds to 127.0.0.1 only - not reachable from the network
  * every API call needs a token minted at startup, and the Host header must be
    loopback, so another page in your browser cannot drive it
  * GET endpoints only read. The single writing endpoint is POST /api/publish,
    and the UI asks you to confirm before calling it
"""
from __future__ import annotations

import argparse, http.server, importlib.util, json, os, pathlib, secrets, socket
import subprocess, sys, threading, urllib.parse, webbrowser

HERE = pathlib.Path(__file__).resolve().parent
def _load(name, filename):
    sp = importlib.util.spec_from_file_location(name, HERE / filename)
    mod = importlib.util.module_from_spec(sp)
    sys.modules[name] = mod
    sp.loader.exec_module(mod)
    return mod

S = _load("asc_sync", "asc-sync.py")
M = _load("asc_media", "asc-media.py")
SHOTS = S.ROOT / S._paths()["screenshots_dir"]

TOKEN = secrets.token_urlsafe(24)
STATE: dict = {"client": None, "error": None}
JOBS: dict = {}


def client() -> S.Client:
    if STATE["client"] is None:
        STATE["client"] = S.Client(S.token, apply=False)
    return STATE["client"]


def notify(title: str, body: str) -> None:
    """macOS notification centre. Best effort - never breaks the request."""
    if sys.platform != "darwin":
        return
    try:
        subprocess.run(["osascript", "-e",
                        f'display notification {json.dumps(body)} with title {json.dumps(title)}'],
                       check=False, capture_output=True, timeout=5)
    except Exception:
        pass


# ── the four things the UI can ask for ──────────────────────────────────────────
def api_bootstrap(_q) -> dict:
    sync = S.load_config()
    return {"bundleId": sync["bundle_id"],
            "locales": [{"code": c, "asc": v["asc"]} for c, v in sync["locales"].items()],
            "editableStates": sorted(S.EDITABLE)}


def api_apps(_q) -> dict:
    apps = client().get_all("/v1/apps?limit=200")
    return {"apps": [{"id": a["id"],
                      "bundleId": a["attributes"].get("bundleId"),
                      "name": a["attributes"].get("name")} for a in apps]}


def api_versions(q) -> dict:
    app = q["app"][0]
    sync = S.load_config()
    vers = client().get_all(
        f"/v1/apps/{app}/appStoreVersions?filter[platform]={sync.get('platform','IOS')}&limit=50")
    return {"versions": [{"id": v["id"],
                          "versionString": v["attributes"].get("versionString"),
                          "state": v["attributes"].get("appStoreState"),
                          "editable": v["attributes"].get("appStoreState") in S.EDITABLE}
                         for v in vers]}


def _gather(app: str, version: str | None, scope: str) -> dict:
    """Everything the preview and the publish both need, computed once."""
    cl, sync = client(), S.load_config()
    out: dict = {"sections": []}

    if scope in ("listing", "all"):
        want = S.desired_listing(sync)
        infos = [i for i in cl.get_all(f"/v1/apps/{app}/appInfos?limit=50")
                 if i["attributes"].get("appStoreState") in S.EDITABLE]
        if not infos:
            raise RuntimeError("No editable App Information. Create a version in "
                               "Prepare for Submission on App Store Connect first.")
        info_id = infos[0]["id"]
        out["sections"].append({
            "key": "appinfo", "title": "App Information", "kind": "appInfoLocalizations",
            "createPath": "/v1/appInfoLocalizations",
            "rel": {"appInfo": {"data": {"type": "appInfos", "id": info_id}}},
            "plan": S.plan_changes(
                cl.get_all(f"/v1/appInfos/{info_id}/appInfoLocalizations?limit=200"),
                want, S.INFO_FIELDS)})
        if not version:
            raise RuntimeError("Pick a version first.")
        out["sections"].append({
            "key": "listing", "title": "Version listing", "kind": "appStoreVersionLocalizations",
            "createPath": "/v1/appStoreVersionLocalizations",
            "rel": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": version}}},
            "plan": S.plan_changes(
                cl.get_all(f"/v1/appStoreVersions/{version}/appStoreVersionLocalizations?limit=200"),
                want, S.listing_fields(cl, app))})

    if scope in ("iap", "all"):
        group_want, sub_want = S.desired_iap(sync)
        groups = cl.get_all(f"/v1/apps/{app}/subscriptionGroups?limit=50")
        if groups:
            gid = groups[0]["id"]
            out["sections"].append({
                "key": "group", "title": "Subscription group", "kind": "subscriptionGroupLocalizations",
                "createPath": "/v1/subscriptionGroupLocalizations",
                "rel": {"subscriptionGroup": {"data": {"type": "subscriptionGroups", "id": gid}}},
                "plan": S.plan_changes(
                    cl.get_all(f"/v1/subscriptionGroups/{gid}/subscriptionGroupLocalizations?limit=200"),
                    {k: {"name": v} for k, v in group_want.items()}, ("name",))})
            live = {s["attributes"]["productId"]: s for s in
                    cl.get_all(f"/v1/subscriptionGroups/{gid}/subscriptions?limit=200")}
            for pid, want_locales in sub_want.items():
                s = live.get(pid)
                if not s:
                    out.setdefault("warnings", []).append(
                        f"{pid} is in {S.storekit_path().name} but not in App Store Connect")
                    continue
                out["sections"].append({
                    "key": f"sub:{pid}", "title": pid, "kind": "subscriptionLocalizations",
                    "createPath": "/v1/subscriptionLocalizations",
                    "rel": {"subscription": {"data": {"type": "subscriptions", "id": s["id"]}}},
                    "plan": S.plan_changes(
                        cl.get_all(f"/v1/subscriptions/{s['id']}/subscriptionLocalizations?limit=200"),
                        want_locales, ("name", "description"))})
    return out


def api_preview(q) -> dict:
    data = _gather(q["app"][0], (q.get("version") or [None])[0], (q.get("scope") or ["all"])[0])
    for s in data["sections"]:
        s.pop("rel", None); s.pop("createPath", None)
    counts = {a: sum(1 for s in data["sections"] for p in s["plan"] if p["action"] == a)
              for a in ("create", "update", "same")}
    data["counts"] = counts
    return data


def api_create_version(body: dict) -> dict:
    sync = S.load_config()
    cl = client(); cl.apply = True
    r = cl._call("POST", "/v1/appStoreVersions", {"data": {
        "type": "appStoreVersions",
        "attributes": {"versionString": body["versionString"],
                       "platform": sync.get("platform", "IOS")},
        "relationships": {"app": {"data": {"type": "apps", "id": body["app"]}}}}})
    cl.apply = False
    return {"id": r["data"]["id"], "versionString": body["versionString"]}


def api_publish(body: dict) -> dict:
    only = set(body.get("locales") or [])
    data = _gather(body["app"], body.get("version"), body.get("scope", "all"))
    cl = client(); cl.apply = True; cl.writes = 0
    written = []
    try:
        for sec in data["sections"]:
            plan = [p for p in sec["plan"] if p["action"] != "same"
                    and (not only or p["locale"] in only)]
            if not plan:
                continue
            errs = S.apply_plan(cl, sec["kind"], plan, sec["createPath"], sec["rel"])
            failed = {e.split(":")[0] for e in errs}
            written.append({"section": sec["title"],
                            "locales": sorted(p["locale"] for p in plan
                                              if p["locale"] not in failed),
                            "errors": errs})
    finally:
        cl.apply = False
    bad = sum(len(w["errors"]) for w in written)
    msg = (f"{cl.writes} field group(s) written across {len(written)} section(s)"
           + (f", {bad} refused." if bad else "."))
    notify("App Store Connect", msg if cl.writes else "Nothing to write - already in sync.")
    return {"writes": cl.writes, "written": written, "message": msg}


# ── screenshots ─────────────────────────────────────────────────────────────────
def api_shots_plan(q) -> dict:
    only = set(filter(None, (q.get("locales") or [""])[0].split(",")))
    sync = S.load_config()
    data = M.plan(client(), q["version"][0], SHOTS, sync["locales"], only or None)
    for r in data["rows"]:
        r.pop("paths", None)
    return data


def _run_upload(job_id: str, version: str, only: set, replace: bool,
                max_passes: int = 5) -> None:
    """Upload, then keep re-checking until nothing is missing.

    Individual requests already retry, but a long run can still lose images to a
    dropped connection at an awkward moment. Since the plan is computed from file
    names, a second pass simply sees the stragglers and sends those - so the job
    finishes itself instead of asking the user to notice and press the button again.
    It stops early when a whole pass adds nothing, rather than looping on a fault
    that retrying cannot fix."""
    job = JOBS[job_id]
    cl = client()
    try:
        sync = S.load_config()
        for attempt in range(1, max_passes + 1):
            rows = [r for r in M.plan(cl, version, SHOTS, sync["locales"], only or None)["rows"]
                    if not r["blocked"]]
            todo = [(r, r["paths"] if (replace and attempt == 1)
                     else [q for q in r["paths"]
                           if pathlib.Path(q).name in set(r["missing"])]) for r in rows]
            todo = [(r, ps) for r, ps in todo if ps]
            remaining = sum(len(ps) for _, ps in todo)
            if not remaining:
                if attempt == 1:
                    job["skipped"] = [f"{r['device']}/{r['locale']}: all {r['existing']} already there"
                                      for r in rows]
                break
            job["pass"] = attempt
            job["total"] = job["done"] + remaining
            if attempt > 1:
                job["errors"].append(f"pass {attempt}: retrying {remaining} image(s) "
                                     f"that did not land")
            before = job["done"]
            cl.apply = True
            for r, paths in todo:
                tag = f"{r['device']}/{r['locale']}"
                set_id = r["setId"] or M.find_or_make_set(cl, r["locId"], r["displayType"], apply=True)
                if replace and attempt == 1:
                    for old in M.existing(cl, set_id):
                        cl._call("DELETE", f"/v1/appScreenshots/{old['id']}")
                for path in paths:
                    job["current"] = f"pass {attempt} · {tag} {pathlib.Path(path).name}"
                    try:
                        M.upload_one(cl, set_id, pathlib.Path(path))
                        job["done"] += 1
                    except SystemExit as e:
                        job["errors"].append(f"{tag} {pathlib.Path(path).name}: {e}")
                    except Exception as e:
                        job["errors"].append(f"{tag} {pathlib.Path(path).name}: "
                                             f"{type(e).__name__}: {e}")
                final = [s["id"] for name in [pathlib.Path(q).name for q in r["paths"]]
                         for s in M.existing(cl, set_id)
                         if s["attributes"].get("fileName") == name]
                if len(final) > 1:
                    try:
                        M.reorder(cl, set_id, final)
                    except Exception as e:
                        job["errors"].append(f"{tag} reorder: {e}")
            if job["done"] == before:
                job["errors"].append(f"pass {attempt} uploaded nothing - stopping so this "
                                     f"does not loop. See the errors above.")
                break
        # Final truth: ask App Store Connect what is actually there.
        left = M.plan(cl, version, SHOTS, S.load_config()["locales"], only or None)
        job["stillMissing"] = [f"{r['device']}/{r['locale']}: {', '.join(r['missing'])}"
                               for r in left["rows"] if r["missing"]]
    except SystemExit as e:
        job["errors"].append(str(e))
    except Exception as e:
        job["errors"].append(f"{type(e).__name__}: {e}")
    finally:
        cl.apply = False
        job["current"] = ""
        job["finished"] = True
        miss = len(job.get("stillMissing") or [])
        notify("App Store Connect",
               f"{job['done']} screenshot(s) uploaded"
               + (f", {miss} set(s) still incomplete" if miss else " - all sets complete"))


def api_shots_start(body: dict) -> dict:
    job_id = secrets.token_hex(8)
    JOBS[job_id] = {"done": 0, "total": 0, "current": "", "errors": [],
                    "skipped": [], "stillMissing": [], "pass": 1, "finished": False}
    threading.Thread(target=_run_upload, daemon=True, args=(
        job_id, body["version"], set(body.get("locales") or []),
        bool(body.get("replace")))).start()
    return {"job": job_id}


def api_shots_progress(q) -> dict:
    job = JOBS.get(q["job"][0])
    return job or {"error": "unknown job"}


GET_ROUTES = {"/api/bootstrap": api_bootstrap, "/api/apps": api_apps,
              "/api/versions": api_versions, "/api/preview": api_preview,
              "/api/screenshots": api_shots_plan, "/api/screenshots/progress": api_shots_progress}
POST_ROUTES = {"/api/publish": api_publish, "/api/version": api_create_version,
               "/api/screenshots/start": api_shots_start}


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "asc-studio"

    def _guard(self) -> bool:
        host = (self.headers.get("Host") or "").rsplit(":", 1)[0].strip("[]")
        if host not in ("127.0.0.1", "localhost", "::1"):
            self._send(403, {"error": "non-loopback Host header refused"}); return False
        if self.headers.get("X-Studio-Token") != TOKEN:
            self._send(403, {"error": "bad or missing session token"}); return False
        return True

    def _send(self, code: int, payload, ctype="application/json"):
        raw = payload if isinstance(payload, bytes) else json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(raw)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        url = urllib.parse.urlparse(self.path)
        if url.path in ("/", "/index.html"):
            html = (HERE / "studio.html").read_text(encoding="utf-8")
            return self._send(200, html.replace("__TOKEN__", TOKEN).encode(),
                              "text/html; charset=utf-8")
        if url.path not in GET_ROUTES:
            return self._send(404, {"error": "not found"})
        if not self._guard():
            return
        try:
            self._send(200, GET_ROUTES[url.path](urllib.parse.parse_qs(url.query)))
        except SystemExit as e:
            self._send(500, {"error": str(e)})
        except Exception as e:
            self._send(500, {"error": f"{type(e).__name__}: {e}"})

    def do_POST(self):
        url = urllib.parse.urlparse(self.path)
        if url.path not in POST_ROUTES:
            return self._send(404, {"error": "not found"})
        if not self._guard():
            return
        try:
            n = int(self.headers.get("Content-Length") or 0)
            body = json.loads(self.rfile.read(n) or b"{}")
            self._send(200, POST_ROUTES[url.path](body))
        except SystemExit as e:
            self._send(500, {"error": str(e)})
        except Exception as e:
            self._send(500, {"error": f"{type(e).__name__}: {e}"})

    def log_message(self, fmt, *a):
        sys.stderr.write(f"  {fmt % a}\n")


def free_port(preferred: int) -> int:
    for p in (preferred, 0):
        with socket.socket() as s:
            try:
                s.bind(("127.0.0.1", p)); return s.getsockname()[1]
            except OSError:
                continue
    raise SystemExit("no free port")


def main() -> int:
    ap = argparse.ArgumentParser(description="Local web console for App Store Connect metadata.")
    ap.add_argument("--port", type=int, default=8787)
    ap.add_argument("--no-open", action="store_true", help="do not open the browser")
    args = ap.parse_args()

    for v in ("ASC_KEY_ID", "ASC_ISSUER_ID", "ASC_KEY_PATH"):
        if not os.environ.get(v):
            print(f"note: {v} is not set - the page will load but App Store Connect "
                  f"calls will fail until you export it.", file=sys.stderr)
            break

    port = free_port(args.port)
    url = f"http://127.0.0.1:{port}/"
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    print(f"\n  App Store Connect studio\n  {url}\n"
          f"  loopback only, session token required. Ctrl-C to stop.\n")
    if not args.no_open:
        threading.Timer(0.4, lambda: webbrowser.open(url)).start()
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\n  stopped")
    return 0


if __name__ == "__main__":
    sys.exit(main())
