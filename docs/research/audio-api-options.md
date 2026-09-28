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

## Nền tảng tổng hợp (aggregator), tra thêm 28/09/2026
Proxy của phiên chặn trang giá trực tiếp của Apiframe, ImaRouter, AIMLAPI, kie.ai; số dưới đây lấy từ kết quả tìm kiếm, **mở trang giá của từng bên để xác nhận**.

| Nền tảng | Cách tính tiền | Giọng ElevenLabs | Nhạc | Suno có chính thức không | Ghi chú |
|---|---|---|---|---|---|
| **Apiframe** | Gói tháng, 1 credit = 0,01 USD; Hobby 19 USD/tháng 2.000 credit, các gói trả phí thường từ 39 USD/tháng; 100 credit miễn phí | có (xem trang) | Eleven Music tính theo độ dài: 0,26 USD (≤30 giây), 1,02 USD (≤2 phút), 2,55 USD (>2 phút) · Lyria 3 Pro 0,10 USD/bài · Mureka 0,06 USD/lượt (2 bài) · Suno, Udio | Không (Suno không có API công khai) | Một key cho hơn 70 model; phải mua gói tháng |
| **ImaRouter** | Trả theo lượt, một key cho LLM, ảnh, video, âm thanh; tự quảng cáo rẻ hơn fal.ai khoảng 66% | có | Suno | Không | Chưa lấy được bảng giá; GitHub: Ima-Router/ima-router |
| **OpenRouter** | Trả theo lượt, không phí tháng | **không có ElevenLabs**; có GPT-4o Mini TTS (0,60 USD/1 triệu ký tự), Gemini 3.1 Flash TTS, Voxtral | Lyria 3 Pro Preview | Không có Suno | Rẻ nhất cho TTS nhưng giọng khác Bella, phải nghe lại |
| **AIMLAPI** | Trả theo lượt | từ 0,0484 USD/1.000 ký tự | Eleven Music 0,15 USD/phút · MiniMax | Không bán Suno | Giá ElevenLabs ngang giá gốc |
| **fal.ai** | Trả theo lượt | 0,10 USD/1.000 ký tự (v3, Multilingual v2), 0,05 (Turbo) | Eleven Music 0,80 USD/phút | Không có Suno | Trang đối tác chính thức với ElevenLabs |
| **WaveSpeedAI**, **Segmind** | Trả theo lượt | 0,10 USD/1.000 ký tự (v3) | Eleven Music | Không | Chọn được model v3, Multilingual v2, Flash |
| **EvoLink**, **kie.ai / sunoapi.org** | Trả theo lượt, gói nạp từ 5 USD | ElevenLabs rẻ hơn khoảng 30% (kie) | Suno khoảng 0,111 USD/lượt (2 bài) | Không, bản dò ngược | Rủi ro điều khoản Suno như mục Kết luận |
| **PiAPI** | Trả theo lượt hoặc thuê tài khoản 5–10 USD/tháng | — | Udio; đã bỏ Suno | Không | Udio cũng không có API công khai |
| **useapi.net** | 15 USD/tháng, cộng gói web của dịch vụ gốc | — | Suno, Mureka qua tài khoản của mình | Không | Điều khiển tài khoản web của mình, rủi ro khoá tài khoản |
| **Google Gemini API** (không phải aggregator) | Trả theo lượt | — | **Lyria 3 Pro 0,08 USD/bài**, Lyria 3 Clip 0,04 USD; có thể tạo nhạc không lời | — | API chính thức, cho phép dùng thương mại; mọi bài có SynthID ẩn |
| **Stability API** (không phải aggregator) | 0,01 USD/credit | — | Stable Audio 2.5: 0,20 USD/bài, tối đa 3 phút | — | Dữ liệu huấn luyện có giấy phép |

**Nhận xét quan trọng:** app không có backend, giọng và nhạc được tạo **một lần** rồi đóng gói vào app. Lợi ích chính của aggregator (một key, định tuyến khi app chạy, một hoá đơn cho nhiều model) gần như không dùng tới. Chỉ cần nguồn rẻ nhất có quyền thương mại rõ ràng cho từng loại.

### Chi phí cho nhu cầu của app (60.000 ký tự giọng, 15 bài nhạc × khoảng 2,5 phút)
| Tổ hợp | Giọng | Nhạc | Tổng | Đánh giá |
|---|---|---|---|---|
| **ElevenLabs trực tiếp (giọng) + Gemini API Lyria 3 Pro (nhạc)** | khoảng 3–6 USD | khoảng 1,2 USD | **khoảng 5–8 USD** | Rẻ nhất trong nhóm chính thức; giữ giọng Bella; cần hai key |
| ElevenLabs Creator 1 tháng (cả hai) | trong gói | trong gói | 22 USD | Một tài khoản, quyền thương mại chắc chắn |
| ElevenLabs trực tiếp, trả theo lượt (cả hai) | khoảng 3–6 USD | khoảng 6 USD | khoảng 9–12 USD | Cần xác nhận trả theo lượt có giấy phép thương mại |
| AIMLAPI (cả hai qua ElevenLabs) | khoảng 3 USD | khoảng 6 USD | khoảng 9 USD | Một key; kiểm tra điều khoản thương mại của AIMLAPI |
| Apiframe (Eleven Music + ElevenLabs TTS) | theo gói | khoảng 38 USD | từ 39 USD/tháng | Đắt vì Eleven Music tính theo bài dài |
| fal.ai (cả hai qua ElevenLabs) | khoảng 6 USD | khoảng 30 USD | khoảng 36 USD | Chính thức nhưng nhạc đắt gấp 5 lần |
| Suno qua EvoLink/kie + ElevenLabs | khoảng 3–6 USD | khoảng 1 USD | khoảng 4–7 USD | **Không nên**: Suno không chính thức |

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
- Apiframe: [giá nhạc 2026](https://apiframe.ai/blog/ai-music-api-pricing-2026) · [gói](https://apiframe.ai/pricing) · [Lyria 3 Pro](https://apiframe.ai/models/lyria-3-pro/pricing) · [Mureka](https://apiframe.ai/models/mureka/pricing)
- ImaRouter: [trang chủ](https://www.imarouter.com/) · [GitHub](https://github.com/Ima-Router/ima-router/)
- OpenRouter: [TTS](https://openrouter.ai/docs/guides/overview/multimodal/tts) · [Lyria 3 Pro Preview](https://openrouter.ai/google/lyria-3-pro-preview) · [audio models](https://openrouter.ai/collections/audio-models)
- AIMLAPI: [ElevenLabs](https://aimlapi.com/providers/elevenlabs) · [Suno](https://aimlapi.com/suno-ai-api)
- EvoLink: [Suno pricing](https://evolink.ai/blog/suno-api-pricing) · PiAPI: [pricing](https://piapi.ai/pricing) · useapi.net: [so sánh API nhạc](https://dev.to/useapi/ai-music-apis-compared-mureka-vs-minimax-vs-elevenlabs-vs-lyria-3-pro-2kcn)
- WaveSpeedAI: [Eleven Music](https://wavespeed.ai/docs/docs-api/elevenlabs/elevenlabs-music) · Segmind: [ElevenLabs TTS](https://www.segmind.com/models/tts-eleven-labs)
- Google Lyria: [invideo](https://invideo.io/blog/lyria-ai-music-generator/) · [CellCog, Lyria 3.5 trong Gemini API](https://cellcog.ai/blog/lyria-3-5/)
