@echo off
TITLE Gemini Audio Engineer Launcher

:: 1. Di chuyển vào thư mục chứa file bat này (để đảm bảo đường dẫn đúng)
cd /d "%~dp0"

echo Dang khoi dong he thong...
echo -----------------------------------

:: 2. Khởi động Backend trong một cửa sổ riêng
echo [1/3] Dang khoi dong Backend Server...
start "Backend Server (Python)" cmd /k "cd backend && .venv\Scripts\activate && uvicorn app:app --reload --port 8000"

:: 3. Khởi động Frontend trong một cửa sổ riêng
echo [2/3] Dang khoi dong Frontend React...
start "Frontend Interface (React)" cmd /k "cd frontend && npm run dev"

:: 4. Đợi 7 giây để server kịp chạy rồi mở trình duyệt
echo [3/3] Dang doi server san sang...
timeout /t 7 >nul

:: 5. Mở trình duyệt mặc định
echo Dang mo trinh duyet...
start http://localhost:5173

exit