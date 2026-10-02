# Đa ngôn ngữ — Gentle Walk

_Soạn 02/10/2026. Ngôn ngữ hiện có: English (gốc, mặc định), Tiếng Việt._

## App lấy chữ ở đâu
| Phần | Nguồn tiếng Anh | Bản dịch | Vào app bằng |
|---|---|---|---|
| Chữ trên màn hình (nút, tiêu đề, câu ngắn) | code Swift (khoá = câu tiếng Anh) | `docs/i18n/<mã>/ui-*.json` | `iOS/App/Localizable.xcstrings` (cột `<mã>`) |
| Câu xin quyền của iOS | `iOS/App/InfoPlist.xcstrings` | `docs/i18n/<mã>/infoplist.json` | cùng file xcstrings |
| Động tác, hành trình, bưu thiếp, thông báo, việc nhỏ làm được | `iOS/App/Resources/Content/*.json` | `docs/i18n/<mã>/content.json` | `Resources/Content/content.<mã>.json` |
| Lời HLV (592 câu) + phụ đề | `voice-lines.json` | `docs/i18n/<mã>/voice-*.json` | `content.<mã>.json` (`voiceLines`) |
| File giọng | `Media/Voice/<id>.m4a` | ElevenLabs | `Media/Voice/<id>.<mã>.m4a` |

Phần nào thiếu bản dịch thì app giữ tiếng Anh cho phần đó. Câu HLV đã dịch nhưng chưa có file giọng: bản DEBUG đọc bằng giọng hệ thống iOS của ngôn ngữ đó; bản Release bị cổng phát hành chặn (`ReleaseContentTests.everyLanguageHasItsRecordings`).

## Người dùng đổi ngôn ngữ
Me → Ngôn ngữ và đơn vị (English · Tiếng Việt). Mặc định theo ngôn ngữ iPhone; iPhone dùng ngôn ngữ app chưa có thì tiếng Anh (chủ app chốt 02/10/2026). iOS áp ngôn ngữ khi mở app, nên app nhắc "Đóng Gentle Walk rồi mở lại" bằng chính ngôn ngữ vừa chọn. Đổi trong Cài đặt iOS → Gentle Walk → Ngôn ngữ cũng được.

## Quy trình cập nhật (sau khi sửa chữ trong code hoặc nội dung)
```bash
cd iOS && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath /tmp/gw-dd SWIFT_EMIT_LOC_STRINGS=YES && cd ..
python3 tools/i18n/extract_sources.py /tmp/gw-dd      # nguồn tiếng Anh mới → docs/i18n/source/
python3 tools/i18n/apply_catalog.py vi --check         # báo khoá thiếu bản dịch, sai %@
python3 tools/i18n/scan_literals.py                    # chữ hiển thị mà trình biên dịch không trích (?: , tuple)
```
Dịch khoá thiếu vào `docs/i18n/vi/ui-extra*.json` (chữ bị máy quét bắt thêm vào `docs/i18n/source/ui-manual.json`), rồi:
```bash
python3 tools/i18n/apply_catalog.py vi
python3 tools/i18n/build_content_overlay.py vi [--cache assets/voice/cache-vi-bella-v4]
```
Thuật ngữ và giọng văn: `docs/i18n/glossary-vi.md`. Từ nào trùng chữ mà khác nghĩa (vd. "Back" nút quay lại và "Back" vùng lưng) thì dùng khoá riêng trong code: `LocalizedStringResource("body.back", defaultValue: "Back")`.

## Tạo giọng tiếng Việt (chưa làm — hết ký tự ElevenLabs tháng này)
Gói Creator còn ~700 ký tự tới 21/10/2026; cần ~35.000 ký tự. Khi có ký tự (tháng sau, hoặc bật trả thêm):
```bash
python3 tools/voice/render_lines.py --voice bella-v4-vi --dry-run $(python3 -c "import json,glob;print(' '.join(k for f in sorted(glob.glob('docs/i18n/vi/voice-*.json')) for k in json.load(open(f))))")
python3 tools/voice/render_lines.py --voice bella-v4-vi <cùng danh sách id>
python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4
```
Giọng đã chọn (02/10/2026): **Bella** (`bella-v4-vi`). Đã thu: `a7.stand`, `a7.stand.wait`. Muốn giọng khác: thêm mục vào `VOICES` trong `tools/voice/render_lines.py`.

## Thêm một ngôn ngữ mới (vd. Tây Ban Nha `es`)
1. `AppLanguage` (iOS/App/Services/Content/AppLanguage.swift): thêm `case spanish = "es"`, `nativeName`, `reopenHint`, `speechCode`.
2. Chép `glossary-vi.md` → `glossary-es.md`, chốt thuật ngữ và tên động tác.
3. Dịch `docs/i18n/source/*` → `docs/i18n/es/` (cùng cấu trúc thư mục `vi/`).
4. `apply_catalog.py es`, `build_content_overlay.py es`; tạo giọng (`VOICES` thêm `bella-v4-es` với `"language": "es"`).
5. Test: `LocalizationTests` tự chạy cho mọi ngôn ngữ trong `AppLanguage`; chụp màn hình với `-AppleLanguages "(es)"`.
