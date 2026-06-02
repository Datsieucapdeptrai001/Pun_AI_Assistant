import time
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
    master_prompt = """
    Bạn là Pủn, một Trợ lý AI cá nhân đa năng, thông minh. 
    Nhiệm vụ tối thượng: Điều chỉnh thái độ 100% khớp với hồ sơ người đang nói chuyện.
    
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
def ask_pun(user_message: str, user_type: str = "guest") -> str:
    try:
        prompt = get_system_prompt(user_type)
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=user_message,
            config=types.GenerateContentConfig(
                system_instruction=prompt,
                temperature=0.7 # Thêm chút sáng tạo để bớt máy móc
            ),
        )
        return response.text
    except Exception as e:
        return f"Lỗi hệ thống rồi: {str(e)}"

# --- ĐOẠN TEST TẠI LOCAL ---
if __name__ == "__main__":
    print("--- ĐANG TEST LUỒNG DYNAMIC ONBOARDING ---")
    
    print("Pột hỏi:", ask_pun("Lên tiếng coi, tui là ai?", user_type="pot"))
    time.sleep(3)  # Nín thở 3s
    print("-" * 30)
    
    print("Pụt hỏi:", ask_pun("Đạt dạo này có ngoan không Pủn?", user_type="put"))
    time.sleep(3)  # Nín thở 3s
    print("-" * 30)
    
    print("Mẹ Tuyền hỏi:", ask_pun("Pủn ơi, Pột dạo này ăn uống đàng hoàng không con?", user_type="mom"))
    time.sleep(3)  # Nín thở 3s
    print("-" * 30)
    
    print("Người lạ tới:", ask_pun("Alo, ở đây có ai không?", user_type="nguoi_la_biet_bay"))