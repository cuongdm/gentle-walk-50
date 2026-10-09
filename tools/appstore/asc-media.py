#!/usr/bin/env python3
"""asc-media.py - screenshot upload against the App Store Connect API.

Apple does not take a screenshot in one request. Each image is a three-step dance:

    POST /v1/appScreenshots        reserve, and get back `uploadOperations`
    PUT  <presigned url> x N       the bytes, in the chunks Apple asked for
    PATCH /v1/appScreenshots/{id}  uploaded=true + an md5 of what you sent

The md5 is how Apple detects a truncated or corrupted upload, so it is computed
from the exact bytes that went over the wire, never from the file a second time.

The presigned PUT must NOT carry our Authorization header - it is already signed,
and adding a second credential makes S3 reject it. That is why this does not reuse
Client._call for the upload leg.

Imported by asc-studio.py; also runnable on its own for one device/locale.
"""
from __future__ import annotations

import hashlib, http.client, pathlib, struct, sys, time
import urllib.error, urllib.request

# The repo renders exactly these two sizes; App Store Connect files them under the
# 6.7" iPhone and 12.9" iPad slots, which is where Apple accepts 6.9" and 13" art.
DISPLAY_TYPES = {
    "iPhone": ("APP_IPHONE_67", (1290, 2796)),
    "iPad":   ("APP_IPAD_PRO_3GEN_129", (2064, 2752)),
}
MAX_PER_SET = 10


def png_size(path: pathlib.Path) -> tuple[int, int]:
    """Width/height straight from the IHDR chunk - no Pillow needed."""
    head = path.open("rb").read(24)
    if head[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path.name} is not a PNG")
    return struct.unpack(">II", head[16:24])


def local_sets(root: pathlib.Path, locales: dict) -> dict:
    """{(device, asc_locale): [Path, ...]} for everything rendered in the repo."""
    found: dict = {}
    for device in DISPLAY_TYPES:
        for code, spec in locales.items():
            d = root / device / code
            if not d.is_dir():
                continue
            files = sorted(d.glob("*.png"))
            if files:
                found[(device, spec["asc"])] = files
    return found


def check_local(files: list[pathlib.Path], device: str) -> list[str]:
    want = DISPLAY_TYPES[device][1]
    problems = []
    if len(files) > MAX_PER_SET:
        problems.append(f"{len(files)} images, App Store Connect allows {MAX_PER_SET}")
    for f in files:
        try:
            got = png_size(f)
        except Exception as e:
            problems.append(f"{f.name}: {e}")
            continue
        if got != want:
            problems.append(f"{f.name}: {got[0]}x{got[1]}, expected {want[0]}x{want[1]}")
    return problems


def find_or_make_set(cl, loc_id: str, display_type: str, apply: bool) -> str | None:
    sets = cl.get_all(f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets?limit=50")
    for s in sets:
        if s["attributes"].get("screenshotDisplayType") == display_type:
            return s["id"]
    if not apply:
        return None
    r = cl._call("POST", "/v1/appScreenshotSets", {"data": {
        "type": "appScreenshotSets",
        "attributes": {"screenshotDisplayType": display_type},
        "relationships": {"appStoreVersionLocalization": {
            "data": {"type": "appStoreVersionLocalizations", "id": loc_id}}}}})
    return r["data"]["id"]


def existing(cl, set_id: str) -> list:
    return cl.get_all(f"/v1/appScreenshotSets/{set_id}/appScreenshots?limit=50")


def missing(cl, set_id: str | None, files: list[pathlib.Path]) -> list[pathlib.Path]:
    """Which local files are not up there yet, matched by file name.

    A set that already holds *some* images is not a set that is done: an upload cut
    short by an expired token leaves 8 of 9, and treating "has any" as "is complete"
    would strand that ninth image forever. Comparing names makes a re-run finish the
    job instead of skipping it, and makes a full re-run cheap."""
    if not set_id:
        return list(files)
    have = {s["attributes"].get("fileName") for s in existing(cl, set_id)}
    return [f for f in files if f.name not in have]


# Apple's blob store drops long-lived connections mid-run; the chunk itself is fine.
NET_ERRORS = (urllib.error.URLError, http.client.HTTPException, OSError)


def _put(op: dict, chunk: bytes, attempts: int = 4) -> None:
    for i in range(1, attempts + 1):
        req = urllib.request.Request(op["url"], data=chunk, method=op.get("method", "PUT"))
        for h in op.get("requestHeaders") or []:
            req.add_header(h["name"], h["value"])      # presigned: no Authorization
        try:
            with urllib.request.urlopen(req, timeout=180):
                return
        except NET_ERRORS:
            if i == attempts:
                raise
            time.sleep(min(1.5 * i, 6))


def upload_one(cl, set_id: str, path: pathlib.Path, attempts: int = 3) -> str:
    """One image, retried as a whole.

    A half-sent image cannot be resumed: the presigned URLs belong to one reservation,
    and re-PUTting into a torn one leaves bytes Apple will checksum-reject. So a failed
    attempt deletes its reservation and starts a clean one rather than pushing on."""
    data = path.read_bytes()
    last: Exception | None = None
    for i in range(1, attempts + 1):
        shot = None
        try:
            r = cl._call("POST", "/v1/appScreenshots", {"data": {
                "type": "appScreenshots",
                "attributes": {"fileName": path.name, "fileSize": len(data)},
                "relationships": {"appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}}}}})
            shot = r["data"]
            for op in shot["attributes"].get("uploadOperations") or []:
                off, ln = op.get("offset", 0), op.get("length", len(data))
                _put(op, data[off:off + ln])
            cl._call("PATCH", f"/v1/appScreenshots/{shot['id']}", {"data": {
                "type": "appScreenshots", "id": shot["id"],
                "attributes": {"uploaded": True,
                               "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
            return shot["id"]
        except NET_ERRORS as e:
            last = e
            if shot:                                   # drop the torn reservation
                try:
                    cl._call("DELETE", f"/v1/appScreenshots/{shot['id']}")
                except Exception:
                    pass
            if i < attempts:
                time.sleep(2.0 * i)
    raise RuntimeError(f"{path.name}: gave up after {attempts} attempts - "
                       f"{type(last).__name__}: {last}")


def reorder(cl, set_id: str, ids: list[str]) -> None:
    """File order is the store order; without this Apple keeps upload order."""
    cl._call("PATCH", f"/v1/appScreenshotSets/{set_id}/relationships/appScreenshots",
             {"data": [{"type": "appScreenshots", "id": i} for i in ids]})


def plan(cl, version_id: str, root: pathlib.Path, locales: dict,
         only_locales: set | None = None) -> dict:
    """What would happen, without changing anything."""
    live = {l["attributes"]["locale"]: l["id"] for l in cl.get_all(
        f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=200")}
    rows, warnings = [], []
    for (device, asc), files in sorted(local_sets(root, locales).items()):
        if only_locales and asc not in only_locales:
            continue
        bad = check_local(files, device)
        warnings += [f"{device}/{asc}: {b}" for b in bad]
        loc_id = live.get(asc)
        if not loc_id:
            warnings.append(f"{device}/{asc}: no version localization on App Store Connect yet")
            continue
        dtype = DISPLAY_TYPES[device][0]
        set_id = find_or_make_set(cl, loc_id, dtype, apply=False)
        M_missing = missing(cl, set_id, files)
        rows.append({"device": device, "locale": asc, "displayType": dtype,
                     "setId": set_id, "locId": loc_id,
                     "files": [f.name for f in files], "paths": [str(f) for f in files],
                     "existing": len(existing(cl, set_id)) if set_id else 0,
                     "missing": [f.name for f in M_missing],
                     "blocked": bool(bad)})
    return {"rows": rows, "warnings": warnings,
            "total": sum(len(r["missing"]) for r in rows if not r["blocked"])}


if __name__ == "__main__":
    print(__doc__)
    print("Display types:")
    for d, (t, s) in DISPLAY_TYPES.items():
        print(f"  {d:7} {t:24} {s[0]}x{s[1]}")
