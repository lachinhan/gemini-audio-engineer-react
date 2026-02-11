@echo off
TITLE Tu Dong Cai Dat Gemini Audio Engineer
COLOR 0A

:: Chuyen ve thu muc hien tai de chay lenh cho dung
cd /d "%~dp0"

echo ========================================================
echo      TU DONG CAI DAT GEMINI AUDIO ENGINEER
echo ========================================================
echo.

:: --- BUOC 1: KIEM TRA CONG CU ---
echo [1/5] Dang kiem tra cac cong cu can thiet...

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] May ban chua cai Python! Vui long cai Python 3.10 tro len truoc.
    pause
    exit
)

npm -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [LOI] May ban chua cai Node.js! Vui long cai Node.js truoc.
    pause
    exit
)
echo - Kiem tra cong cu: OK.
echo.

:: --- BUOC 2: CAI DAT BACKEND ---
echo [2/5] Dang thiet lap Backend (Python)...
cd backend

:: Tao moi truong ao neu chua co
if not exist .venv (
    echo - Dang tao moi truong ao (.venv)...
    python -m venv .venv
)

:: Cai thu vien
echo - Dang cai dat thu vien Python (buoc nay hoi lau chut)...
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\pip install -r requirements.txt

:: Tao file .env neu chua co
if not exist .env (
    echo - Dang tao file cau hinh .env...
    copy .env.example .env >nul
)
echo.

:: --- BUOC 2.5: NHAP API KEY (MOI) ---
echo --------------------------------------------------------
echo [QUAN TRONG] CAU HINH API KEY
echo --------------------------------------------------------
echo Vui long dan (Paste) ma Google Gemini API Key cua ban vao duoi day.
echo (Neu chua co, cu bam Enter de bo qua va tu dien sau)
echo.
set /p API_KEY="> Dan API Key vao day va bam Enter: "

if "%API_KEY%" neq "" (
    echo.
    echo - Dang luu API Key vao file backend/.env...
    :: Dung PowerShell de thay the dong key trong bang key cua ban
    powershell -Command "(gc .env) -replace 'GEMINI_API_KEY=', 'GEMINI_API_KEY=%API_KEY%' | Set-Content .env"
    echo - Da luu API Key thanh cong!
) else (
    echo - Da bo qua. Ban nho tu mo file backend/.env de dien sau nhe.
)

:: Quay lai thu muc goc
cd ..
echo - Cai dat Backend: OK.
echo.

:: --- BUOC 3: CAI DAT FRONTEND ---
echo [3/5] Dang thiet lap Frontend (Node.js)...
cd frontend

:: Cai thu vien Node
echo - Dang cai dat thu vien giao dien (vui long doi)...
call npm install

:: Quay lai thu muc goc
cd ..
echo - Cai dat Frontend: OK.
echo.

:: --- BUOC 4: KIEM TRA FFMPEG ---
echo [4/5] Dang kiem tra FFmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo - Khong tim thay FFmpeg. Dang thu cai tu dong bang Winget...
    winget install Gyan.FFmpeg
) else (
    echo - FFmpeg da co san trong may.
)
echo.

:: --- BUOC 5: HOAN TAT ---
echo ========================================================
echo                  CAI DAT HOAN TAT!
echo ========================================================
echo.
echo Bay gio ban co the chay file "Start-App.bat" de su dung ngay.
echo.
pause