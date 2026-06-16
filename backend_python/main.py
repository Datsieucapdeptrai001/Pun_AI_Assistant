from fastapi import FastAPI
from pydantic import BaseModel
from backend_python.ai_engine import ask_pun

app = FastAPI(title="Pủn AI API Hệ Sinh Thái")

# ĐÃ XÓA TẤT CẢ CODE LIÊN QUAN ĐẾN StaticFiles VÀ LƯU FILE LOCAL

class ChatRequest(BaseModel):
    user_type: str = "guest"
    message: str

@app.post("/api/chat")
async def chat_with_pun(request_data: ChatRequest):
    print(f"📥 Nhận tin nhắn từ [{request_data.user_type}]: {request_data.message}")
    
    # Hàm ask_pun bây giờ siêu việt rồi, nó gọi FPT và trả về cái Dictionary:
    # {"reply_text": "...", "audio_url": "link_cua_fpt"}
    result = ask_pun(request_data.message, request_data.user_type)
    
    reply_text = result.get("reply_text", "")
    audio_url = result.get("audio_url", None)
    
    # Bắt lỗi nếu não bộ đứt cáp
    if reply_text.startswith("Lỗi rùi"):
        status = "error"
    else:
        status = "success"
    
    # Bắn thẳng link FPT xuống cho điện thoại phát nhạc
    return {
        "status": status,
        "reply_text": reply_text,
        "audio_url": audio_url 
    }

# Endpoint để Render check ping (UptimeRobot)
@app.get("/")
async def root():
    return {"message": "Não bộ Pủn AI đang hoạt động cực mạnh!"}