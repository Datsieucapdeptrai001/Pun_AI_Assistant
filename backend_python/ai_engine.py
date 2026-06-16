import datetime
import time
import re
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

# 1. Load biến môi trường
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise ValueError("Ê Pột! Quên bỏ GEMINI_API_KEY vào file .env rồi kìa!")

# 2. Khởi tạo Client
client = genai.Client(api_key=API_KEY)

# 3. CƠ SỞ DỮ LIỆU NHÂN CÁCH (Tách Data khỏi Logic)
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

# 4. MASTER PROMPT - LÕI NHẬN THỨC ĐỘNG
def get_system_prompt(user_type: str) -> str:
    # 1. Lấy thời gian thực tế của server
    current_time = datetime.datetime.now().strftime("%A, ngày %d/%m/%Y lúc %H:%M:%S")
    
    master_prompt = f"""
    Bạn là Pủn, một Trợ lý AI cá nhân đa năng, thông minh.
    
    [THÔNG TIN HỆ THỐNG QUAN TRỌNG]:
    - Thời gian hiện tại của thế giới thực: {current_time}
    - BẮT BUỘC sử dụng mốc thời gian này khi nói về ngày, tháng, thời tiết.
    - TUYỆT ĐỐI KHÔNG SỬ DỤNG định dạng Markdown (như dấu **, *, #). CHỈ ĐƯỢC DÙNG văn bản thuần túy (Plain Text) và dấu câu cơ bản. Nếu vi phạm, hệ thống âm thanh sẽ bị lỗi!
    
    HỒ SƠ NGƯỜI ĐỐI DIỆN:
    """
    
    # Kéo profile từ Database ảo, nếu không có thì gán mác Người Lạ
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

# 5. HÀM GIAO TIẾP CHÍNH
# Cập nhật lại Hàm giao tiếp chính
def ask_pun(user_message: str, user_type: str = "guest") -> str:
    prompt = get_system_prompt(user_type)
    
    # Số lần mặt dày gọi lại API nếu bị Google từ chối
    max_retries = 3 
    
    for attempt in range(max_retries):
        try:
            # Cập nhật khối gọi API
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=user_message,
                config=types.GenerateContentConfig(
                    system_instruction=prompt,
                    temperature=0.7,
                    # ĐÂY CHÍNH LÀ CHÌA KHÓA: Cấp quyền cho AI tự search Google để lấy data thật!
                    tools=[{"google_search": {}}] 
                ),
            )
            # Lấy câu trả lời thô từ AI
            raw_text = response.text
            
            # DÙNG VŨ LỰC: Cạo sạch mọi dấu *, #, _, và ` (backtick)
            clean_text = re.sub(r'[*#_`]', '', raw_text)
            
            return clean_text
            
        except Exception as e:
            error_msg = str(e).lower()
            
            # Nếu dính Rate Limit (429) hoặc Kẹt server (503) -> Chờ rồi gọi lại
            if "429" in error_msg or "503" in error_msg:
                if attempt < max_retries - 1:
                    # Lần 1 đợi 1s, Lần 2 đợi 2s, Lần 3 đợi 4s...
                    sleep_time = 2 ** attempt 
                    print(f"⚠️ [CẢNH BÁO] Google đang thở oxy! Chờ {sleep_time}s rồi đấm lại lần {attempt + 2}...")
                    time.sleep(sleep_time)
                    continue # Vòng lại đầu for để đấm tiếp
            
            # Nếu là lỗi khác (sai key, mất mạng) hoặc đã thử 3 lần vẫn xịt thì mới chịu thua
            return f"Lỗi rùi: Trời ơi mạng mẽo chán quá, não tui đang bị đứt cáp mất rồi. {str(e)}"

    return "Lỗi rùi: Google Server đang sập, Pột ráng đợi xíu rùi hỏi lại tui nha!"