from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import os
import time

# Import Não và Miệng của Pủn
from backend_python.ai_engine import ask_pun
from backend_python.voice_engine import speak_like_pun

app = FastAPI(title="Pủn AI API Hệ Sinh Thái")

# 1. Tạo thư mục chứa file âm thanh (nếu chưa có)
os.makedirs("audio_output", exist_ok=True)

# 2. Mở cổng cho phép người ngoài tải file MP3 từ thư mục này
app.mount("/audio", StaticFiles(directory="audio_output"), name="audio")

# 3. Định nghĩa Khuôn dữ liệu đầu vào
class ChatRequest(BaseModel):
    user_type: str = "guest"
    message: str

# 4. API Endpoint chính xử lý cả Text và Voice
@app.post("/api/chat")
async def chat_with_pun(request: ChatRequest):
    print(f"📥 Nhận tin nhắn từ [{request.user_type}]: {request.message}")
    
    # Bước 1: Gọi NÃO xử lý logic chữ
    text_response = ask_pun(request.message, request.user_type)
    
    # BƯỚC BẢO MẬT: Bắt lỗi 500/503 để mỏ Pủn không đọc tiếng Anh tào lao
    if text_response.startswith("Lỗi hệ thống"):
        print("⚠️ Google sập nguồn, đang bật khiên phản hồi ảo!")
        text_response = "Trời ơi mạng mẽo chán quá, não tui đang bị đứt cáp mất rồi. Pột đợi tui 1 phút rồi hỏi lại nha!"
    
    # Bước 2: Tạo tên file MP3 độc nhất
    filename = f"pun_voice_{int(time.time())}.mp3"
    filepath = f"audio_output/{filename}"
    
    # Bước 3: Gọi MIỆNG đọc file 
    speak_like_pun(text_response, filepath)
    
    # Bước 4: Trả kết quả về
    return {
        "status": "success" if not text_response.startswith("Trời ơi") else "error",
        "reply_text": text_response,
        "audio_url": f"http://localhost:8000/audio/{filename}" 
    }