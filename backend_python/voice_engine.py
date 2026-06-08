from gtts import gTTS
import os

def speak_like_pun(text: str, output_file: str = "pun_voice.mp3"):
    """
    Hàm biến chữ thành file âm thanh MP3.
    """
    print(f"🎙️ Đang rặn giọng nói cho câu: '{text[:40]}...'")
    try:
        # lang='vi' là tiếng Việt, tld='com.vn' để lấy giọng chuẩn Việt Nam
        tts = gTTS(text=text, lang='vi', tld='com.vn', slow=False)
        tts.save(output_file)
        print(f"✅ Đã xuất file âm thanh thành công: {output_file}")
        return output_file
    except Exception as e:
        print(f"❌ Lỗi bể giọng rồi: {e}")
        return None

# --- ĐOẠN TEST CHẠY THỬ ---
if __name__ == "__main__":
    cau_noi = "Chào Pột, tui là Pủn đây! Ông mới lên Sài Gòn thì cày code nhẹ nhàng thôi, code xong nhớ ngủ sớm giữ sức khỏe nha."
    
    # Chạy hàm tạo âm thanh
    file_mp3 = speak_like_pun(cau_noi)
    
    # Lệnh này ép Windows tự động mở file MP3 lên phát luôn (chỉ chạy trên máy tính của ông)
    if file_mp3:
        os.system(f"start {file_mp3}")