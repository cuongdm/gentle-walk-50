# Bàn giao cloud → Mac: `cloud/m5-review` (08/10/2026)

Nhánh tạo từ `origin/mac/integration` 3461f6c. Nhánh chỉ sửa docs và bản dịch; không sửa Swift, `Localizable.xcstrings` hay `project.yml`.

## Trạng thái

| # | Việc | Trạng thái | File | Mac cần làm |
|---|---|---|---|---|
| 1 | Rà soát tĩnh App Review / tuân thủ | DONE: 0 Critical, 2 Important, 3 Minor | `docs/reviews/2026-10-08-app-review-recheck.md` §1–3 | Sửa I-1 (số ngày dùng thử đọc từ `introductoryOffer`), M-1 (câu mục đích Health + chính sách riêng tư), M-2 (ẩn Close ở bước vị trí). I-2 ("Not now" ở S16) cần chủ app chốt lại D5 |
| 2 | Duyệt tiếng Việt ui-extra-9…12 + giọng A12, A13, a8 | DONE: 54 câu (52 giao diện, 2 giọng) | `docs/i18n/vi/ui-extra-{9,10,11,12}.json`, `voice-a12.json`, `voice-a8b.json`; nhật ký ở review §4 | `python3 tools/i18n/apply_catalog.py vi`, rồi thu lại `a12.check.setup` và `a8.camino.4` (lệnh ở review §4), rồi chạy overlay với `--cache` |
| 3 | Docs: decisions log, screen spec, screenshots, review notes | DONE | `app-context.md` (decisions log 08/10: font A1 + chiều sâu mềm, Phosphor, P1–P13, nội dung chống nhàm chán, rà soát; thêm dòng hệ hình ảnh và paywall gọn); `docs/design/gentle-walk-screen-spec.html` (Design tokens theo code, S15 lời khen, S16 hai màn, S17 Hôm nay, S19 Progress, S20 Me); `docs/release/1.0/screenshots.md` (chụp lại, ảnh thay thế, ảnh cho người duyệt); `docs/release/1.0/checklist.md` §5 (HealthKit + ngày đi lại nhiều, paywall gọn, cá nhân hoá trên máy) | Chụp lại ảnh store theo lệnh trong screenshots.md; khi sửa I-2 thì cập nhật câu "Not now" trong review notes và S16 |

## Bằng chứng (chạy trên cloud, 08/10/2026)

- `python3 tools/i18n/apply_catalog.py vi --check`: `vi: 929 of 929 UI keys translated; 0 missing; 0 problems`.
- `python3 tools/lint/copy_lint.py`: `0 findings`. Chạy thêm trên các file vi đã sửa: cũng `0 findings`.
- GentleWalkCore (Docker swift 6.2): `Test run with 265 tests in 56 suites passed`. Có chạy `noConflictingTranslations` và các test phủ tiếng Việt.
- Không key nào có hai bản dịch khác nhau giữa các file `docs/i18n/vi/ui*.json`.
- Spec HTML: kiểm cân thẻ bằng `html.parser`, trước và sau đều 0 lỗi.
- `copy_lint.py` sau mục 3: `0 findings`.

## Lưu ý cho phiên Mac
- Thứ tự cho hai câu giọng vi: chạy `render_lines.py --voice bella-v4-vi a12.check.setup a8.camino.4` **trước**, rồi `build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4`. Làm ngược lại thì overlay bỏ bản ghi của hai câu này.
- Các hex màu và cỡ chữ trong spec lấy từ asset catalog và `Typography.swift` ngày 08/10. Nếu đổi token, sửa spec cùng commit.
