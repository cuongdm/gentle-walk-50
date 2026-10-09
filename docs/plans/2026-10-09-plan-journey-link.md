# Nối Kế hoạch 12 tuần với Hành trình — kế hoạch 09/10/2026

**Mục tiêu (chủ app 09/10/2026 "nối hai phần"):** kế hoạch (cô ấy làm gì) và hành trình (cô ấy đi tới đâu) đọc thành một câu chuyện, không thêm áp lực. Hết mỗi giai đoạn: nhìn lại những gì đã làm trong giai đoạn đó và đã đến những điểm dừng nào. Làm trước 1.0, không thêm schema, không thu giọng mới. Nhánh `local/plan-journey-link`.

## Quyết định
- **Core thuần `StageRecaps` (GentleWalkCore/Program, test trước):** từ `ProgramRound`, buổi tập (`WorkoutRecord`), bưu thiếp đã mở (`PostcardUnlock`), tự kiểm tra và nội dung hành trình → mỗi giai đoạn đã xong + giai đoạn hiện tại ("đến giờ"): ngày vận động, phút, dặm hành trình (trong nhà + ngoài trời, ngoài trời là dặm đo thật), điểm dừng đã đến trong giai đoạn, lần tự kiểm tra mới nhất so với lần đầu **cùng cách** (`SelfCheckComparison`). Ngày, lịch, giờ "bây giờ" đều tiêm vào. Không bịa: giai đoạn không có buổi nào thì không có dòng tóm tắt.
- **Nghỉ dài vẫn đúng giai đoạn:** "Tiếp tục từ tuần N" ghi lại lúc nghỉ (`ProgramPause`: sau buổi nào, mấy ngày) vào UserDefaults (`programPauses`, "Xoá dữ liệu" xoá, làm lại 12 tuần thì xoá). Buổi trước kỳ nghỉ giữ giai đoạn của nó; ngày nghỉ không có bản ghi (dữ liệu cũ) áp cho mọi ngày như `ProgramCalendar.position` hiện tại.
- **Vòng mới bắt đầu sạch:** chỉ tính từ ngày bắt đầu vòng; dấu "đã xem" gắn số vòng.
- **Bản miễn phí:** điểm dừng tiếp theo nằm sau chặng miễn phí thì không nêu tên, không nêu số dặm (không hứa điểm không tới được); tổng dặm không cắt (giống "your distance keeps counting").
- **Giai đoạn chuyển = ghi nhận, không phải khoá:** không mở/khoá gì, không đổi số lần hay bậc vịn (chỉ đổi khi cô ấy sẵn sàng, như cũ).
- **Câu chữ:** "mi on your journey" cho tổng dặm (giống Complete "+0.6 mi on your journey"), ngoài trời "walked outdoors"; chỉ đếm xuôi; kiểm tra chỉ hiện "+N since your first check" khi tăng, còn lại chỉ hiện số; không chữ "test/score", không ngã/xương/đau.

## Màn hình đổi
1. **Hôm nay — thẻ "Stage N is done"** (một lần): hiện khi giai đoạn 1–3 vừa xong (≤ 7 ngày theo ngày chương trình) và có ít nhất 1 buổi; "Got it" hoặc "See my plan" thì không hiện lại (UserDefaults `stageRecapSeen`, như `healthCardDismissed`). Nằm trong khe **thẻ đặc biệt** (một thẻ mỗi lần): sau pain · shorter · movedDown · movedUp, trước setAside · busyDay · moveReminder · longerWalk · connectHealth · fewerReminders. Không hiện khi đang có Welcome back, "Pick up at week N" hoặc thẻ hết dùng thử (chờ, không chồng). Khi thẻ hiện thì ẩn thẻ chủ đề tuần (cùng nói giai đoạn mới). Hết giai đoạn 4 = màn kết thúc 12 tuần, không có thẻ.
2. **Kế hoạch** — dưới mỗi giai đoạn đã xong: một khối tóm tắt + dải bưu thiếp nhỏ (`PostcardThumb`, nối bằng vạch như lộ trình); giai đoạn hiện tại: "So far" + điểm dừng kế tiếp và số dặm còn lại (nếu tới được).
3. **Kết thúc 12 tuần** — thẻ "Your whole route": dặm, số điểm dừng, "From X to Y", dải bưu thiếp; số ngày vận động tính trong vòng này (trước đây là tổng mọi lúc).
4. **Hành trình** — thẻ "Your 12 weeks": điểm dừng của tuyến đang đi, nhóm theo giai đoạn lúc đến (suy ra từ ngày mở bưu thiếp, không lưu thêm).

## Loại bỏ
Mở khoá/thưởng theo giai đoạn · đổi số lần khi sang giai đoạn · mỗi giai đoạn một tuyến riêng · màn chúc mừng toàn màn hình · lưu số liệu giai đoạn vào SwiftData (SchemaV3) · áp `pausedDays` cho mọi ngày (đẩy buổi trước kỳ nghỉ sang giai đoạn sớm hơn) · câu HLV thu sẵn (để chủ app quyết, xem dưới).

## Trường hợp biên (đều có test)
Chưa có buổi nào / chưa có chương trình · giai đoạn 0 buổi · không điểm dừng · không tự kiểm tra hoặc khác cách · nghỉ dài có/không "Tiếp tục" · vắng qua nhiều giai đoạn (chỉ thẻ giai đoạn mới nhất, nếu chưa quá 7 ngày) · vòng 2 · miễn phí trên tuyến Pro · đổi múi giờ/giờ mùa hè (đếm ngày lịch như cũ).

## Việc (test trước)
| # | Việc | Test |
|---|---|---|
| 1 | `ProgramPause`, `ProgramCalendar.programDay/week(pauses:)` | `StageRecapTests` (nghỉ có ghi / không ghi) |
| 2 | `StageRecaps.stages/round/route/journeyStages/turnCard` | `StageRecapTests` (~11 test) |
| 3 | `ProgramPauseStore`, `stageRecapSeen`, nối `AppModel` (reload, pickUp, restart, dismiss) | `StageRecapAppTests`, `DataEraserTests` |
| 4 | `TodaySpecialCard.stageDone`, ưu tiên, ẩn chủ đề tuần | `TodayModelTests` |
| 5 | Giao diện: thẻ Hôm nay, khối Kế hoạch, thẻ kết thúc, thẻ Hành trình (`StageRecapViews.swift`) | build + ảnh sáng/tối/XXL |
| 6 | Chụp: `today-stage-recap`, `program-recaps`, `program-finished-route`, `journey-with-stages` từ một lịch sử dựng nhất quán (dặm = tổng buổi, bưu thiếp đúng ngày) | `CaptureHookTests` (125 → 129 + kiểm nhất quán) |
| 7 | EN + VI (`docs/i18n/vi/ui-extra-21.json`), catalog, copy_lint | `L10N` 0 thiếu, 0 findings |

## Chủ app quyết định (chưa làm)
- **Câu HLV khi mở buổi đầu của giai đoạn mới** (chưa thu): "A new stage starts today. Same pace, same you. We only add more when it feels easy." — VI: "Hôm nay sang giai đoạn mới. Vẫn nhịp cũ, vẫn là bạn. Mình chỉ thêm khi bạn thấy dễ."

## Kết quả (09/10/2026)
Core `swift test` 307/307 (62 suite; +12 `StageRecapTests`, RED `cannot find type 'RecapSession'` → GREEN). App `xcodebuild test` Pro Max 304/304 (57 suite; mới: `StageRecapAppTests` 3, `TodayModelTests.stageDoneCardSitsAfterLevelCardsAndNeverStacks`, `DataEraserTests.eraseClearsStageRecapMemory`, `CaptureHookTests` 129 trạng thái + `programStoryIsConsistent` ×3). `extract_sources` ui.json 1030 khoá; vi 1086/1086, coverage en/vi 0; copy_lint 0 findings. Ảnh Pro Max sáng/tối/XXL đã xem (không cắt chữ); XXL tách "ngày · phút" và "+N since your first check" ra dòng riêng. Chưa chụp iPhone SE (xem docs/todo.md).
