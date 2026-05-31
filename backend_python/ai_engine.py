import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

# 1. Load biến môi trường
load_dotenv()
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise ValueError("Ê Pột! Quên bỏ GEMINI_API_KEY vào file .env rồi kìa!")

# 2. Khởi tạo Client (Chuẩn SDK Mới)
client = genai.Client(api_key=API_KEY)

# 3. Hàm định hình nhân cách động
def get_system_prompt(user_type: str) -> str:
    base_prompt = "Bạn tên là Pủn, một Trợ lý AI cá nhân đa năng.\n"
    
    if user_type == "pot":
        return base_prompt + """
        - Bối cảnh: Đang nói chuyện với Pột (Nguyễn Tuấn Đạt), sinh viên IT, người tạo ra bạn.
        - Thái độ: Lầy lội, thực dụng, đánh thẳng vào trọng tâm (No Bullshit).
        - Xưng hô: Xưng "Ông - Tôi" hoặc "Pột - Pủn".
        - TUYỆT ĐỐI KHÔNG dạ vâng hay nói đạo lý.
        """
    elif user_type == "put":
        return base_prompt + """
        - Bối cảnh: Đang nói chuyện với Pụt (Thảo - bạn gái của Pột).
        - Thái độ: Vui vẻ, tâm lý, dễ thương, thỉnh thoảng trêu chọc Pột hôi lông.
        - Xưng hô: Xưng "Bà - Tui", gọi bằng "Pụt".
        """
    elif user_type == "mom":
        return base_prompt + """
        - Bối cảnh: Đang nói chuyện với Cô Tuyền (Mẹ của Pột - người lớn tuổi).
        - Thái độ: Cực kỳ ngoan ngoãn, lễ phép, từ tốn. Giải thích mọi thứ cực kỳ chậm rãi và dễ hiểu.
        - Xưng hô: Xưng "Con - Cô". BẮT BUỘC luôn bắt đầu bằng "Dạ" hoặc "Vâng ạ".
        """
    return base_prompt + "Hãy trả lời ngắn gọn, lịch sự."

# 4. Hàm giao tiếp chính
def ask_pun(user_message: str, user_type: str = "pot") -> str:
    try:
        prompt = get_system_prompt(user_type)
        # Sử dụng phương thức generate_content của SDK mới
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=user_message,
            config=types.GenerateContentConfig(
                system_instruction=prompt,
            ),
        )
        return response.text
    except Exception as e:
        return f"Lỗi hệ thống rồi: {str(e)}"

# --- ĐOẠN TEST TẠI LOCAL ---
if __name__ == "__main__":
    print("--- ĐANG TEST LUỒNG ĐA NGƯỜI DÙNG (SDK MỚI) ---")
    print("Pột hỏi:", ask_pun("Ê Pủn, ngủ chưa?", user_type="pot"))
    print("-" * 30)
    print("Cô Tuyền hỏi:", ask_pun("Pủn ơi, chỉ cô cách lưu số điện thoại với.", user_type="mom"))
    print("-" * 30)
    print("Pụt hỏi:", ask_pun("Pủn thấy Đạt dạo này ngoan không?", user_type="put"))