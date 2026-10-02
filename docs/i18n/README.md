# Đa ngôn ngữ — Gentle Walk

_Soạn 02/10/2026. Ngôn ngữ hiện có: English (gốc, mặc định), Tiếng Việt._

## App lấy chữ ở đâu
| Phần | Nguồn tiếng Anh | Bản dịch | Vào app bằng |
|---|---|---|---|
| Chữ trên màn hình (nút, tiêu đề, câu ngắn) | code Swift (khoá = câu tiếng Anh) | `docs/i18n/<mã>/ui-*.json` | `iOS/App/Localizable.xcstrings` (cột `<mã>`) |
| Câu xin quyền của iOS | `iOS/App/InfoPlist.xcstrings` | `docs/i18n/<mã>/infoplist.json` | cùng file xcstrings |
| Động tác, hành trình, bưu thiếp, thông báo, việc nhỏ làm được | `iOS/App/Resources/Content/*.json` | `docs/i18n/<mã>/content.json` | `Resources/Content/content.<mã>.json` |
| Lời HLV (593 câu) + phụ đề | `voice-lines.json` | `docs/i18n/<mã>/voice-*.json` | `content.<mã>.json` (`voiceLines`) |
| File giọng | `Media/Voice/<id>.m4a` | ElevenLabs qua Vibi | `Media/Voice/<id>.<mã>.m4a` |

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

## Tạo giọng HLV (qua Vibi — đã xong tiếng Việt 02/10/2026)
Giọng **Bella** (`bella-v4-vi`, ElevenLabs eleven_v4) tạo qua **Vibi** (vibi.pro, đối tác ElevenLabs), trả bằng credit Vibi (1 credit/ký tự), không tốn ký tự gói ElevenLabs. Khoá ở `~/.config/vibi/api_key`. Thời điểm từng chữ (phụ đề, nhịp đếm) lấy từ speech to text của Vibi khớp với câu gốc: sai trung bình 0,05 s (đo trên 119 chữ so với alignment gốc ElevenLabs).
```bash
python3 tools/voice/render_lines_vibi.py --voice bella-v4-vi --all --dry-run   # đếm câu/ký tự chưa thu
python3 tools/voice/render_lines_vibi.py --voice bella-v4-vi --all --workers 6 # thu mọi câu chưa có trong cache
python3 tools/voice/qc_lines.py vi                                             # kiểm chất lượng → docs/i18n/vi/qc-report.md
python3 tools/i18n/build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4
```
Câu sửa chữ thì cache tự coi là câu mới (khoá = băm nội dung), lệnh `--all` chỉ thu câu đó. QC báo "render again" (nghe sai chữ, im lặng lạ, vỡ tiếng): xoá cặp mp3/json của câu đó trong cache rồi chạy lại; hai lần vẫn sai thì đổi cách viết câu. Cờ "length/fit" chỉ để biết, cổng phát hành và nhịp buổi tập đã chịu được.

Lần thu 02/10/2026: 593/593 câu, ~26.000 credit (+ ~300 thu lại và QC), 33,8 phút giọng (tiếng Anh 35,8). Nghe thử: `docs/i18n/vi/nghe-thu-giong-viet.m4a` (danh sách câu ở file .md cùng tên).

## Thêm một ngôn ngữ mới (vd. Tây Ban Nha `es`)
1. `AppLanguage` (iOS/App/Services/Content/AppLanguage.swift): thêm `case spanish = "es"`, `nativeName`, `reopenHint`, `speechCode`.
2. Chép `glossary-vi.md` → `glossary-es.md`, chốt thuật ngữ và tên động tác.
3. Dịch `docs/i18n/source/*` → `docs/i18n/es/` (cùng cấu trúc thư mục `vi/`).
4. `apply_catalog.py es`, `build_content_overlay.py es`; tạo giọng (`VOICES` thêm `bella-v4-es` với `"language": "es"`).
5. Test: `LocalizationTests` tự chạy cho mọi ngôn ngữ trong `AppLanguage`; chụp màn hình với `-AppleLanguages "(es)"`.
