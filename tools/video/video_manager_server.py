#!/usr/bin/env python3
"""Local server for assets/video/video-manager.html with a reversible "delete clip" action.

Serves the repo root on http://127.0.0.1:8765/ (open /assets/video/video-manager.html) and adds:
  GET  /api/ping              -> {"ok": true}
  POST /api/trash   {"file"}  -> moves assets/video/<file> to assets/video/_trash/<date>/<file>, rebuilds the page
  POST /api/restore {}        -> moves the most recently trashed file back, rebuilds the page
Only files under assets/video/ can be trashed (never _trash itself, never the app bundle in iOS/):
an app clip is replaced, not deleted. Nothing is deleted permanently; empty _trash by hand.

Usage: python3 tools/video/video_manager_server.py [--port 8765]
"""
import datetime, http.server, json, shutil, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from build_video_manager import ROOT, VIDEO, build  # noqa: E402

TRASH = VIDEO / "_trash"
LOG = TRASH / "trash-log.json"


def load_log():
    return json.loads(LOG.read_text()) if LOG.exists() else []


def trash(rel_file: str) -> dict:
    src = (VIDEO / rel_file).resolve()
    if VIDEO.resolve() not in src.parents or TRASH.resolve() in src.parents:
        raise ValueError("chỉ xoá được file trong assets/video/")
    if not src.is_file() or src.suffix.lower() != ".mp4":
        raise ValueError("không tìm thấy file mp4")
    rel = src.relative_to(VIDEO.resolve())
    dst = TRASH / datetime.date.today().isoformat() / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(src), str(dst))
    log = load_log()
    log.append({"from": str(rel), "to": str(dst.relative_to(VIDEO)), "at": datetime.datetime.now().isoformat(timespec="seconds")})
    LOG.write_text(json.dumps(log, indent=1, ensure_ascii=False))
    return log[-1]


def restore() -> dict:
    log = load_log()
    if not log:
        raise ValueError("thùng rác trống")
    last = log.pop()
    dst, src = VIDEO / last["from"], VIDEO / last["to"]
    if dst.exists():
        raise ValueError(f"{last['from']} đã tồn tại")
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(src), str(dst))
    LOG.write_text(json.dumps(log, indent=1, ensure_ascii=False))
    return last


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=str(ROOT), **kw)

    def reply(self, code, body):
        data = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/api/ping":
            return self.reply(200, {"ok": True, "trash": len(load_log())})
        return super().do_GET()

    def do_POST(self):
        try:
            body = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))) or b"{}")
            if self.path == "/api/trash":
                done = trash(str(body.get("file", "")))
            elif self.path == "/api/restore":
                done = restore()
            else:
                return self.reply(404, {"ok": False, "error": "không có API này"})
            build(True)
            self.reply(200, {"ok": True, **done, "trash": len(load_log())})
        except Exception as e:  # report every failure to the page instead of dropping the request
            self.reply(400, {"ok": False, "error": str(e)})


if __name__ == "__main__":
    port = int(sys.argv[sys.argv.index("--port") + 1]) if "--port" in sys.argv else 8765
    url = f"http://127.0.0.1:{port}/assets/video/video-manager.html"
    try:
        server = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    except OSError:
        sys.exit(f"Port {port} is already in use — the manager is probably running already: open {url}\n"
                 f"(or start another one with --port {port + 1})")
    print(url)
    server.serve_forever()
