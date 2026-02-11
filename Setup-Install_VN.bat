@echo off
TITLE Gemini Audio Engineer - Auto Installer
COLOR 0A

:: 1. Đảm bảo script chạy đúng thư mục hiện tại
cd /d "%~dp0"

echo ========================================================
echo      TU DONG CAI DAT MOI TRUONG GEMINI AUDIO ENGINEER
echo ========================================================
echo.

:: --- PHẦN 1: KIỂM TRA CÔNG CỤ ---
echo [1/5] Kiem tra cac cong cu can thiet...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] Ban chua cai Python! Hay cai Python 3.10+ truoc.
    pause
    exit
)

npm -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] Ban chua cai Node.js! Hay cai Node.js truoc.
    pause
    exit
)
echo -> Cong cu OK.
echo.

:: --- PHẦN 2: CÀI ĐẶT BACKEND ---
echo [2/5] Thiet lap Backend (Python)...
cd backend

:: Tạo môi trường ảo nếu chưa có
if not exist .venv (
    echo -> Dang tao moi truong ao (.venv)...
    python -m venv .venv
) else (
    echo -> Moi truong ao da ton tai.
)

:: Cài đặt thư viện vào môi trường ảo
echo -> Dang cai dat thu vien Python (co the mat vai phut)...
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\pip install -r requirements.txt

:: Tạo file .env nếu chưa có
if not exist .env (
    echo -> Dang tao file .env tu file mau...
    copy .env.example .env
) else (
    echo -> File .env da ton tai.
)

:: Quay lại thư mục gốc
cd ..
echo -> Backend OK.
echo.

:: --- PHẦN 3: CÀI ĐẶT FRONTEND ---
echo [3/5] Thiet lap Frontend (Node.js)...
cd frontend

:: Cài đặt node_modules
echo -> Dang cai dat thu vien Node.js (vui long doi)...
call npm install

:: Quay lại thư mục gốc
cd ..
echo -> Frontend OK.
echo.

:: --- PHẦN 4: CÀI ĐẶT FFMPEG (Tùy chọn) ---
echo [4/5] Kiem tra FFmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo -> Ban chua cai FFmpeg. Dang thu cai dat tu dong bang Winget...
    winget install Gyan.FFmpeg
    echo Luu y: Neu cai dat FFmpeg that bai, hay cai thu cong.
) else (
    echo -> FFmpeg da duoc cai dat.
)
echo.

:: --- PHẦN 5: HOÀN TẤT ---
echo ========================================================
echo                  CAI DAT HOAN TAT!
echo ========================================================
echo.
echo QUAN TRONG:
echo 1. Hay mo file "backend/.env" va dien API KEY cua ban vao.
echo 2. Sau do chay file "Start-App.bat" de bat dau su dung.
echo.
pause