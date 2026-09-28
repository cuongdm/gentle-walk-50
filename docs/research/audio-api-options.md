# Giọng và nhạc AI: nền tảng, giấy phép, chi phí
_28/09/2026 · Tra cứu web, giá lấy từ trang tổng hợp và trang nhà cung cấp, **verify lại trên trang giá chính thức trước khi trả tiền** · Liên quan: docs/todo.md #4, mục "Trước khi đóng gói giọng"_

## Kết luận
**Dùng một tài khoản ElevenLabs trả phí cho cả giọng và nhạc.** ElevenLabs có API chính thức cho giọng (TTS) và nhạc (Eleven Music), quyền thương mại có từ gói Starter, và Eleven Music được huấn luyện trên dữ liệu có giấy phép (Merlin, Kobalt). Không cần nền tảng trung gian. Script `tools/video/build_preview.py` đã gọi thẳng API ElevenLabs, nên chỉ cần đổi key.

**Không dùng API Suno qua bên trung gian** (sunoapi.org, kie.ai, apiframe…). Suno chưa có API công khai; các "Suno API" là bản dò ngược, chạy bằng tài khoản Suno bị điều khiển tự động, trái điều khoản của Suno về truy cập tự động. Rủi ro: khoá tài khoản và quyền thương mại không rõ. Nếu vẫn muốn nhạc Suno thì tạo tay trên web với gói Pro.

## Nhu cầu của app (ước tính)
| Hạng mục | Khối lượng | Quy ra |
|---|---|---|
| Giọng | 490–600 câu × khoảng 70 ký tự, cộng 50% làm lại | khoảng 60.000 ký tự |
| Nhạc nền | 3 phong cách × 3–5 bản × 2–3 phút | khoảng 40 phút |

## So sánh
| Lựa chọn | Giọng | Nhạc | Thương mại | Chi phí ước tính cho app |
|---|---|---|---|---|
| **ElevenLabs Creator, trả 1 tháng rồi huỷ** (khuyên dùng) | 121.000 credit/tháng, khoảng 1 credit/ký tự | Eleven Music 900 credit/phút → 40 phút ≈ 36.000 credit | Có, từ Starter; loại trừ phim, TV, game trên gói tự phục vụ | khoảng 22 USD, đủ cả hai trong một tháng |
| ElevenLabs Starter, 2–3 tháng | 30.000 credit/tháng | cùng credit | Có | khoảng 12–18 USD, lâu hơn |
| ElevenLabs pay-as-you-go API | 0,10 USD/1.000 ký tự (Multilingual v2), 0,05 (Flash/Turbo) | 0,15 USD/phút | Cần xác nhận PAYG có kèm giấy phép thương mại | khoảng 6 + 6 USD |
| fal.ai (bán lại ElevenLabs) | 0,10 USD/1.000 ký tự (v3, Multilingual v2) | 0,80 USD/phút | fal ghi "commercial use" | khoảng 6 + 32 USD, nhạc đắt hơn |
| kie.ai | ElevenLabs rẻ hơn khoảng 30% | "Suno API" không chính thức | Suno qua kie: không an toàn | không khuyên dùng cho nhạc |
| Suno Pro trên web (không API) | — | 10 USD/tháng, 20 lượt tải/tháng là giới hạn phát hành | Có trên gói trả phí, chỉ bài tải khi đang trả phí | khoảng 10 USD cho 15 bản |
| Stable Audio 2.5 API (Stability) | — | 0,20 USD/bản, tối đa 3 phút | Huấn luyện trên dữ liệu có giấy phép; kiểm tra giấy phép Stability cho app | khoảng 3 USD |

Hai nguồn lệch nhau về giá Eleven Music (0,15 USD/phút ở trang tổng hợp giá chính thức, 0,80 USD/phút ở fal và kie). Con số rẻ là giá trực tiếp từ ElevenLabs, con số đắt là giá bán lại.

## Việc cần làm khi nâng gói
1. Mua ElevenLabs Creator một tháng. Lưu hoá đơn và ảnh chụp trang điều khoản có ngày.
2. Tạo lại toàn bộ câu thoại (xoá `assets/voice/cache/` cũ vì tạo bằng gói Free). Nghe lại Bella so với 3 giọng thư viện trước khi tạo hàng loạt.
3. Tạo nhạc bằng Eleven Music: không lời, 2–3 phút, đầu và cuối khớp để lặp; ghi prompt và ngày tạo cho từng bài.
4. Huỷ gói trước kỳ gia hạn nếu không cần thêm.

## Nguồn
- Suno chưa có API công khai, mới mở form đăng ký 01/07/2026: [Music Business Worldwide](https://www.musicbusinessworldwide.com/suno-explores-developer-api-seeking-apps-that-unlock-experiences-generative-music-makes-possible-for-the-first-time/) · [AIMLAPI, rủi ro wrapper](https://aimlapi.com/blog/the-suno-api-reality) · [Suno Terms](https://suno.com/terms-of-service)
- Quyền thương mại Suno theo gói: [Dynamoi](https://dynamoi.com/learn/ai-music-distribution/suno-commercial-rights-explained) · [Suno Help](https://help.suno.com/en/categories/550145-rights-ownership)
- Eleven Music API, dữ liệu có giấy phép: [ElevenLabs](https://elevenlabs.io/eleven-music-api) · [invideo](https://invideo.io/blog/elevenlabs-music-ai-generator/)
- Giá ElevenLabs và PAYG: [ElevenLabs API pricing](https://elevenlabs.io/pricing/api) · [ElevenLabs blog PAYG](https://elevenlabs.io/blog/weve-lowered-api-agents-pricing-and-introduced-pay-as-you-go) · [Cekura](https://www.cekura.ai/blogs/elevenlabs-pricing) · [BIGVU](https://bigvu.tv/blog/elevenlabs-pricing-2026-plans-credits-commercial-rights-api-costs/)
- fal.ai: [Eleven v3](https://fal.ai/models/fal-ai/elevenlabs/tts/eleven-v3) · [ElevenLabs trên fal](https://fal.ai/elevenlabs)
- kie.ai: [Suno API](https://kie.ai/suno-api) · [docs](https://docs.kie.ai/)
- Stable Audio 2.5: [The Rundown](https://www.therundown.ai/tools/stable-audio-2-5) · [Dynamoi](https://dynamoi.com/learn/ai-music-distribution/can-i-distribute-stable-audio-commercially)
