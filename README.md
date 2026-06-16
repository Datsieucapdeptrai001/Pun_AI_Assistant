<div align="center">
  <a href="https://skillicons.dev">
    <img src="https://skillicons.dev/icons?i=fastapi,flutter,python" alt="Tech Stack" />
  </a>
</div>

<h1 align="center">🤖 Pủn AI Assistant</h1>

<p align="center">
  <strong>Hệ thống Đặc vụ Trí tuệ Nhân tạo Cá nhân (Personal AI Agent) được tối ưu hóa cho trải nghiệm Voice-First.</strong>
</p>

<p align="center">
  <a href="#giới-thiệu-dự-án">Giới Thiệu</a> •
  <a href="#tính-năng-nổi-bật">Tính Năng</a> •
  <a href="#kiến-trúc-hệ-thống-microservices">Kiến Trúc</a> •
  <a href="#cài-đặt--khởi-chạy-local-development">Cài Đặt</a> •
  <a href="#cây-thư-mục-dự-án">Cấu Trúc</a>
</p>

---

## Giới Thiệu Dự Án

**Pủn AI Agent** được thiết kế đặc biệt với tiêu chí **"Zero-UI"** (Giao diện tối giản). Mục tiêu cốt lõi của dự án là phá bỏ rào cản công nghệ, giúp đối tượng người dùng lớn tuổi dễ dàng tương tác, tìm kiếm thông tin và nhận hướng dẫn thông qua giao tiếp bằng giọng nói tự nhiên, loại bỏ hoàn toàn các thao tác phức tạp trên màn hình cảm ứng.

## Tính Năng Nổi Bật

*   **🎙️ Giao diện 1 Điểm chạm (One-Touch / Auto-Listen):** Loại bỏ hoàn toàn thanh công cụ, menu và bàn phím phức tạp. Hệ thống tự động lắng nghe ngay khi người dùng mở ứng dụng.
*   **🧠 Não bộ LLM & RAG:** Tích hợp sức mạnh của **Google Gemini 2.5 Flash API** kết hợp cùng Vector Database để truy xuất tài liệu cá nhân, đảm bảo phản hồi chính xác và phù hợp với ngữ cảnh.
*   **🗣️ Phản hồi Thời gian thực (Real-time Voice):** Chuyển đổi giọng nói thành văn bản (STT) siêu tốc và phản hồi lại bằng giọng nói (TTS) thân thiện, tự nhiên.
*   **🎭 Cơ chế Phân quyền Thông minh (Role-based Context):** Tự động điều chỉnh UI và System Prompt theo phân loại người dùng:
    *   **👑 Admin Mode:** Giao diện Chatbot nâng cao, từ vựng chuyên ngành, dùng để quản lý và kiểm tra hệ thống.
    *   **👴 Elderly Mode:** Giao diện tối giản, giọng điệu từ tốn, phản hồi chậm rãi và hướng dẫn chi tiết.

## Kiến Trúc Hệ Thống (Microservices)

Dự án được thiết kế theo kiến trúc Microservices, chia thành 2 phân hệ độc lập:

1.  **Backend (Python / FastAPI):**
    *   Lõi xử lý AI (`ai_engine.py`) đảm nhận việc tối ưu Prompt và giao tiếp với Gemini API.
    *   Cổng giao tiếp (`main.py`) quản lý luồng dữ liệu chuẩn JSON thông qua Pydantic.
    *   Sẵn sàng triển khai trên các nền tảng Cloud (Render, Railway, VPS).

2.  **Frontend (Flutter / Dart):**
    *   Ứng dụng Mobile đa nền tảng (Android/iOS).
    *   Quản lý luồng âm thanh hai chiều (STT thu âm & TTS phát lại).

## Công Nghệ Sử Dụng

*   **Backend:** Python 3.x, FastAPI, Uvicorn, Google GenAI SDK
*   **Frontend:** Flutter, Dart
*   **AI Models:** Google Gemini 2.5 Flash
*   **Architecture:** RESTful API, WebSockets (Dự kiến)

## Cài Đặt & Khởi Chạy (Local Development)

### Yêu cầu tiên quyết (Prerequisites)
*   Python 3.10+
*   Flutter SDK
*   Gemini API Key hợp lệ

### 1. Khởi chạy Backend (Python)

```bash
# Di chuyển vào thư mục backend
cd backend_python

# Kích hoạt môi trường ảo (Windows)
.\.venv\Scripts\Activate.ps1

# (Hoặc) Kích hoạt môi trường ảo (macOS/Linux)
source .venv/bin/activate

# Cài đặt các thư viện cần thiết
pip install -r requirements.txt

# Chạy server FastAPI
uvicorn main:app --reload
```

### 2. Khởi chạy Frontend (Flutter)

```bash
# Di chuyển vào thư mục frontend
cd frontend_flutter

# Cài đặt các package dependencies
flutter pub get

# Chạy ứng dụng trên máy ảo hoặc thiết bị thật
flutter run
```

## Cây Thư Mục Dự Án

```text
.
├── backend_python/             # Não bộ AI (Chạy trên Cloud)
│   ├── .env                    # Biến môi trường (API Keys - KHÔNG PUSH LÊN GIT)
│   ├── .env.example            # Template biến môi trường
│   ├── ai_engine.py            # Xử lý Logic LLM & System Prompt
│   ├── main.py                 # Cổng giao tiếp API (FastAPI)
│   ├── requirements.txt        # Danh sách thư viện Python
│   └── voice_engine.py         # Xử lý giọng nói
│
└── frontend_flutter/           # Giao diện App Mobile
    ├── lib/
    │   ├── main.dart           # File khởi động App
    │   ├── services/
    │   │   └── api_service.dart# Giao tiếp HTTP/WebSockets với Backend
    │   └── ui/
    │       ├── admin_chat_screen.dart  # Màn hình Chat Text cho Admin
    │       ├── auto_listen_screen.dart # Màn hình Zero-UI (Thu âm tự động)
    │       ├── login_screen.dart       # Màn hình đăng nhập
    │       └── router.dart             # Xử lý luồng: Admin vào Chat, User vào Mic
    └── pubspec.yaml            # Khai báo thư viện Flutter
```

## Đóng Góp (Contributing)
Mọi đóng góp (Pull Request, Issues, Suggestions) đều được hoan nghênh. Vui lòng tạo Issue trước khi thực hiện những thay đổi lớn.

## Giấy phép (License)
Dự án được phân phối dưới giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.