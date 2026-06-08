from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import os
import time

from backend_python.ai_engine import ask_pun
from backend_python.voice_engine import speak_like_pun

app = FastAPI(title="Pủn AI API Hệ Sinh Thái")

os.makedirs("audio_output", exist_ok=True)
app.mount("/audio", StaticFiles(directory="audio_output"), name="audio")

class ChatRequest(BaseModel):
    user_type: str = "guest"
    message: str

# THÊM Request VÀO ĐÂY ĐỂ BẮT ĐƯỜNG LINK
@app.post("/api/chat")
async def chat_with_pun(request_data: ChatRequest, req: Request):
    print(f"📥 Nhận tin nhắn từ [{request_data.user_type}]: {request_data.message}")
    
    text_response = ask_pun(request_data.message, request_data.user_type)
    
    if text_response.startswith("Lỗi hệ thống"):
        text_response = "Trời ơi mạng mẽo chán quá, não tui đang bị đứt cáp mất rồi. Pột đợi tui 1 phút rồi hỏi lại nha!"
    
    filename = f"pun_voice_{int(time.time())}.mp3"
    filepath = f"audio_output/{filename}"
    
    speak_like_pun(text_response, filepath)
    
    # LẤY DOMAIN ĐỘNG (Render hay Local nó tự biết)
    base_url = str(req.base_url).rstrip("/")
    
    return {
        "status": "success" if not text_response.startswith("Trời ơi") else "error",
        "reply_text": text_response,
        "audio_url": f"{base_url}/audio/{filename}" 
    }