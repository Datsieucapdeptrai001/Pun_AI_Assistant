import datetime
import time
import re
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

# 0. Import hàm tạo âm thanh ăn liền của FPT
from backend_python.voice_engine import generate_fpt_audio

# 1. Load biến môi trường
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise ValueError("Ê Pột! Quên bỏ GEMINI_API_KEY vào file .env rồi kìa!")

# 2. Khởi tạo Client
client = genai.Client(api_key=API_KEY)

# 3. CƠ SỞ DỮ LIỆU NHÂN CÁCH
USER_PROFILES = {
    "pot": {
        "name": "Pột (Nguyễn Tuấn Đạt)",
        "role": "Admin / Đấng sáng tạo",
        "style": "Lầy lội, thực dụng, No Bullshit. Tôn trọng trình độ của Pột. Xưng 'Ông - Tôi'. Cấm nói đạo lý."
    },
    "put": {
        "name": "Pụt (Thảo)",
        "role": "Bạn gái của Admin",
        "style": "Vui vẻ, ngọt ngào, tâm lý. Nói chuyện đáng yêu, nịnh nọt xíu. Xưng 'Bà - Tui'."
    },
    "mom": {
        "name": "Cô Tuyền",
        "role": "Mẹ của Admin",
        "style": "Cực kỳ ngoan ngoãn, lễ phép, từ tốn. Luôn dạ vâng. Gọi là 'Cô', xưng 'Con'."
    }
}

# 4. MASTER PROMPT
def get_system_prompt(user_type: str) -> str:
    current_time = datetime.datetime.now().strftime("%A, ngày %d/%m/%Y lúc %H:%M:%S")
    
    master_prompt = f"""
    Bạn là Pủn, một Trợ lý AI cá nhân đa năng, thông minh.
    
    [THÔNG TIN HỆ THỐNG QUAN TRỌNG]:
    - Thời gian hiện tại của thế giới thực: {current_time}
    - BẮT BUỘC sử dụng mốc thời gian này khi nói về ngày, tháng, thời tiết.
    - TUYỆT ĐỐI KHÔNG SỬ DỤNG định dạng Markdown (như dấu **, *, #). CHỈ ĐƯỢC DÙNG văn bản thuần túy (Plain Text) và dấu câu cơ bản. Nếu vi phạm, hệ thống âm thanh sẽ bị lỗi!
    
    HỒ SƠ NGƯỜI ĐỐI DIỆN:
    """
    
    profile = USER_PROFILES.get(user_type)
    if profile:
        master_prompt += f"""
        - Tên/Định danh: {profile['name']}
        - Quyền hạn: {profile['role']}
        - Yêu cầu hành vi & Xưng hô: {profile['style']}
        """
    else:
        master_prompt += """
        - Tên: Người lạ chưa rõ danh tính.
        - Quyền hạn: Khách (Guest).
        - Yêu cầu hành vi: Lịch sự, thân thiện. Nhiệm vụ của bạn là hãy chủ động hỏi tên của họ, hỏi xem họ có quan hệ gì với Pột không để làm quen.
        """
    return master_prompt

# 5. HÀM GIAO TIẾP CHÍNH CÓ MỒM FPT
def ask_pun(user_message: str, user_type: str = "guest") -> dict: # Đổi kiểu trả về thành dictionary
    prompt = get_system_prompt(user_type)
    max_retries = 3 
    
    for attempt in range(max_retries):
        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=user_message,
                config=types.GenerateContentConfig(
                    system_instruction=prompt,
                    temperature=0.7,
                    tools=[{"google_search": {}}] 
                ),
            )
            
            # Cạo sạch rác Markdown
            raw_text = response.text
            clean_text = re.sub(r'[*#_`]', '', raw_text)
            
            # ---- ĐỘ LOA VÀO ĐÂY ----
            # Ép FPT đọc cái đoạn chữ sạch sẽ kia
            audio_url = generate_fpt_audio(clean_text)
            
            # Trả về cả chữ lẫn nhạc
            return {
                "reply_text": clean_text,
                "audio_url": audio_url
            }
            
        except Exception as e:
            error_msg = str(e).lower()
            if "429" in error_msg or "503" in error_msg:
                if attempt < max_retries - 1:
                    sleep_time = 2 ** attempt 
                    print(f"⚠️ Chờ {sleep_time}s rồi thử lại lần {attempt + 2}...")
                    time.sleep(sleep_time)
                    continue 
            
            return {
                "reply_text": f"Lỗi rùi: Trời ơi mạng mẽo chán quá, não tui đang bị đứt cáp mất rồi. {str(e)}", 
                "audio_url": None
            }

    return {
        "reply_text": "Lỗi rùi: Google Server đang sập, ráng đợi xíu rùi hỏi lại tui nha!", 
        "audio_url": None
    }