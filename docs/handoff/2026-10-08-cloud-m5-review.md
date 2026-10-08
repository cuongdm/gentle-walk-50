# Bàn giao cloud → Mac: `cloud/m5-review` (08/10/2026)

Nhánh tạo từ `origin/mac/integration` 3461f6c. Nhánh chỉ sửa docs và bản dịch; không sửa Swift, `Localizable.xcstrings` hay `project.yml`.

## Trạng thái

| # | Việc | Trạng thái | File | Mac cần làm |
|---|---|---|---|---|
| 1 | Rà soát tĩnh App Review / tuân thủ | DONE: 0 Critical, 2 Important, 3 Minor | `docs/reviews/2026-10-08-app-review-recheck.md` §1–3 | Sửa I-1 (số ngày dùng thử đọc từ `introductoryOffer`), M-1 (câu mục đích Health + chính sách riêng tư), M-2 (ẩn Close ở bước vị trí). I-2 ("Not now" ở S16) cần chủ app chốt lại D5 |
| 2 | Duyệt tiếng Việt ui-extra-9…12 + giọng A12, A13, a8 | DONE: 54 câu (52 giao diện, 2 giọng) | `docs/i18n/vi/ui-extra-{9,10,11,12}.json`, `voice-a12.json`, `voice-a8b.json`; nhật ký ở review §4 | `python3 tools/i18n/apply_catalog.py vi`, rồi thu lại `a12.check.setup` và `a8.camino.4` (lệnh ở review §4), rồi chạy overlay với `--cache` |
| 3 | Docs: decisions log, screen spec, screenshots, review notes | đang làm | | |

## Bằng chứng (chạy trên cloud, 08/10/2026)

- `python3 tools/i18n/apply_catalog.py vi --check`: `vi: 929 of 929 UI keys translated; 0 missing; 0 problems`.
- `python3 tools/lint/copy_lint.py`: `0 findings`. Chạy thêm trên các file vi đã sửa: cũng `0 findings`.
- GentleWalkCore (Docker swift 6.2): `Test run with 265 tests in 56 suites passed`. Có chạy `noConflictingTranslations` và các test phủ tiếng Việt.
- Không key nào có hai bản dịch khác nhau giữa các file `docs/i18n/vi/ui*.json`.
