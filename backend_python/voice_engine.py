import os
import requests
from dotenv import load_dotenv

# Nạp biến môi trường từ file .env
load_dotenv()

def generate_fpt_audio(text: str, voice_model: str = "linhsan") -> str:
    """
    Gọi API FPT để biến chữ thành Link Âm Thanh (Giọng nữ miền Nam - linhsan).
    """
    print(f"🎙️ Đang nhờ FPT đọc câu: '{text[:40]}...'")
    
    api_key = os.getenv("FPT_API_KEY")
    if not api_key:
        print("❌ Lỗi: Chưa có FPT_API_KEY trong file .env!")
        return None

    url = "https://api.fpt.ai/hmi/tts/v5"
    
    # Cắt ngắn text để an toàn Quota FPT (100k ký tự/tháng)
    safe_text = text[:400]
    payload = safe_text.encode('utf-8')
    
    headers = {
        'api-key': api_key,
        'speed': '', # Để trống là tốc độ chuẩn
        'voice': voice_model
    }
    
    try:
        response = requests.post(url, data=payload, headers=headers)
        response.raise_for_status() # Tự động quăng lỗi nếu API FPT sập
        
        result = response.json()
        if "async" in result:
            audio_link = result["async"]
            print(f"✅ Đã có link nhạc FPT: {audio_link}")
            return audio_link # FPT trả về cái Link URL, mình quăng cái Link này cho App
        else:
            print(f"❌ FPT trả về lỗi: {result}")
            return None
            
    except Exception as e:
        print(f"❌ Lỗi gọi API FPT TTS: {e}")
        return None