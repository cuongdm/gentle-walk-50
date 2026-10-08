# A8b — Câu HLV khi tới điểm dừng: 4 hành trình Pro · bản nháp 1 (CHỜ CHỦ APP DUYỆT, CHƯA THU)
_08/10/2026 · Chống nhàm chán #7 ([icon-va-chong-nham-chan.md](../design/research-2026-10-08/icon-va-chong-nham-chan.md) §5, T11): mỗi tuyến Pro có 6 câu như New York (câu `.1` đã có trong [A-min-support.md](A-min-support.md) §A8). Luật A8: không logo, không tên thương hiệu, không tuyên bố lịch sử hay số liệu cần kiểm chứng, mô tả cảm giác nơi chốn; câu ≤ 14 chữ; không gọi tên. Chữ thoại tiếng Anh Mỹ._

## Câu mới (20) — cần thu EN + VI qua Vibi
| ID | Điểm dừng | Câu thoại | Ghi chú |
|---|---|---|---|
| a8.smoky.2 | Laurel Falls | Laurel Falls. Listen for the water, and take a breath. | |
| a8.smoky.3 | Clingmans Dome | Clingmans Dome, high up in the Smokies. Look how far you've come. | |
| a8.smoky.4 | Mingus Mill | Mingus Mill, an old mill beside a mountain stream. | |
| a8.smoky.5 | Mabry Mill | Mabry Mill, on the Blue Ridge Parkway. A lovely place to rest. | |
| a8.smoky.6 | Linn Cove Viaduct | The Linn Cove Viaduct. You've walked the whole way. Well done. | |
| a8.camino.2 | Portomarín | Portomarín, a town above the river. Keep your easy pace. | |
| a8.camino.3 | Palas de Rei | Palas de Rei, a welcome stop for walkers on the Camino. | |
| a8.camino.4 | Melide | Melide. More of the Camino is behind you than ahead. | |
| a8.camino.5 | O Pedrouzo | O Pedrouzo. The last stop before Santiago. | |
| a8.camino.6 | Obradoiro Square | Obradoiro Square, in Santiago. You walked the Camino. Well done. | |
| a8.ne.2 | Nubble Light | Nubble Light, on its little island just off the shore. | |
| a8.ne.3 | Portsmouth Harbor | Portsmouth Harbor. Boats, water, and your steady steps. | |
| a8.ne.4 | Rockport | Rockport, a harbor town by the sea. Keep going at your pace. | |
| a8.ne.5 | Plymouth | You've reached Plymouth, on the Massachusetts shore. | |
| a8.ne.6 | Nauset Light | Nauset Light, on Cape Cod. You walked the whole route. Well done. | |
| a8.pch.2 | Point Lobos | Point Lobos. Rocky coves and the sound of the ocean. | |
| a8.pch.3 | Bixby Bridge | Bixby Bridge, high above a canyon by the sea. | |
| a8.pch.4 | Pfeiffer Beach | Pfeiffer Beach. Take a moment, then carry on at your pace. | |
| a8.pch.5 | McWay Falls | McWay Falls, where a waterfall meets the beach. | |
| a8.pch.6 | Hearst Castle | Hearst Castle, on the hill above the coast. You made it. Well done. | |

## Bản Việt
`docs/i18n/vi/voice-a8b.json` (20 câu; tên địa danh giữ nguyên theo glossary).

## Phát khi nào
Tới điểm dừng (bưu thiếp mới mở): `JourneyCoach.lineID(journeyID:stopIndex:)` trong core trả id `a8.<tuyến>.<thứ tự điểm>`; mỗi điểm một câu, không lặp.

## Thu giọng (phiên Mac)
`render_lines_vibi.py --voice bella-v4 --ids a8.smoky.2-6,a8.camino.2-6,a8.ne.2-6,a8.pch.2-6` (hoặc `--all` để lấy câu thiếu) → `build_manifest.py` → `qc_lines.py`; VI `--voice bella-v4-vi` → `build_content_overlay.py vi --cache assets/voice/cache-vi-bella-v4`.
