from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from backend_python.ai_engine import ask_pun

# Khởi tạo App FastAPI
app = FastAPI(title="Pủn AI Assistant API")

# Định nghĩa "Bảo vệ gác cổng" (Ép kiểu dữ liệu từ App gửi lên)
class ChatRequest(BaseModel):
    user_type: str
    message: str

# Mở cổng API dạng POST
@app.post("/api/chat")
async def chat_endpoint(request: ChatRequest):
    # Kiểm tra xem user_type có hợp lệ không
    valid_users = ["pot", "put", "mom"]
    if request.user_type not in valid_users:
        raise HTTPException(
            status_code=400, 
            detail=f"Ê, user_type bị sai rồi! Chỉ nhận: {valid_users}"
        )

    try:
        # Chọc vào Lõi AI để lấy câu trả lời
        reply = ask_pun(user_message=request.message, user_type=request.user_type)
        
        # Trả về kết quả dạng JSON chuẩn
        return {
            "status": "success",
            "reply": reply
        }
    except Exception as e:
         raise HTTPException(status_code=500, detail=str(e))