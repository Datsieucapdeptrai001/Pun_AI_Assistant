# 🤖 Trợ Lý AI Cá Nhân (Pủn AI Agent)

## 📖 Giới Thiệu Dự Án
**Pủn AI Agent** là một hệ thống Đặc vụ Trí tuệ Nhân tạo Cá nhân (Personal AI Agent) được thiết kế đặc biệt với tiêu chí "Zero-UI" (Giao diện tối giản). 
Mục tiêu cốt lõi của dự án là phá bỏ rào cản công nghệ, giúp người lớn tuổi dễ dàng tương tác, tìm kiếm thông tin và nhận hướng dẫn thông qua giao tiếp bằng giọng nói tự nhiên, thay vì phải thao tác phức tạp trên màn hình cảm ứng.

## ✨ Tính Năng Nổi Bật
*   **🎙️ Giao diện 1 Điểm chạm (One-Touch / Auto-Listen):** Loại bỏ hoàn toàn thanh công cụ, menu và bàn phím. Người dùng chỉ cần mở App là hệ thống tự động lắng nghe.
*   **🧠 Não bộ LLM & RAG:** Tích hợp Gemini API kết hợp cùng Vector Database để truy xuất tài liệu cá nhân, đưa ra hướng dẫn chính xác theo ngữ cảnh.
*   **🗣️ Phản hồi Thời gian thực (Real-time Voice):** Chuyển đổi giọng nói thành văn bản (STT) và phản hồi lại bằng giọng nói (TTS) thân thiện, dễ nghe.
*   **🎭 Cơ chế Phân quyền (Role-based Context):** Tự động điều chỉnh giọng điệu và giao diện (UI) dựa trên người dùng:
    *   **Admin Mode:** Giao diện Chatbot nâng cao, xưng hô chuyên ngành, dùng để quản lý hệ thống.
    *   **Elderly Mode:** Giao diện tối giản, giọng điệu từ tốn, hướng dẫn chi tiết.

## 🏗️ Kiến Trúc Hệ Thống (Microservices)
Dự án được chia thành 2 module độc lập:
1.  **Backend (Python/FastAPI):** Triển khai trên Cloud (Render/Railway), xử lý AI, Prompt Engineering và giao tiếp API.
2.  **Frontend (Flutter):** Đóng gói thành Mobile App (Android APK), làm nhiệm vụ thu âm và phát lại âm thanh.

## 📂 Cây Thư Mục Dự Án (Directory Tree)

.
├── backend_python/             # Não bộ AI (Chạy trên Cloud)
│   ├── main.py                 # Cổng giao tiếp API (FastAPI)
│   ├── ai_engine.py            # Xử lý Logic LLM & System Prompt
│   ├── voice_service.py        # Tích hợp dịch vụ STT & TTS
│   ├── requirements.txt        # Danh sách thư viện Python
│   └── .env                    # Biến môi trường (API Keys - KHÔNG PUSH LÊN GIT)
│
└── frontend_flutter/           # Giao diện App Mobile
    ├── lib/
    │   ├── main.dart           # File khởi động App & Phân luồng User
    │   ├── api_service.dart    # Giao tiếp HTTP/WebSockets với Backend
    │   └── ui/
    │       ├── router.dart             # Xử lý luồng: Admin vào Chat, User vào Mic
    │       ├── auto_listen_screen.dart # Màn hình Zero-UI (Thu âm tự động)
    │       └── admin_chat_screen.dart  # Màn hình Chat Text cho Admin
    ├── pubspec.yaml            # Khai báo thư viện Flutter
    └── README.md               # Tài liệu dự án