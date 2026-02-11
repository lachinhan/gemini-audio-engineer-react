@echo off
TITLE Gemini Audio Engineer - Auto Installer
COLOR 0A

:: 1. Ensure the script runs from the current directory
cd /d "%~dp0"

echo ========================================================
echo      GEMINI AUDIO ENGINEER - AUTOMATED SETUP
echo ========================================================
echo.

:: --- STEP 1: CHECK PREREQUISITES ---
echo [1/5] Checking required tools...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed! Please install Python 3.10+ first.
    pause
    exit
)

npm -v >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed! Please install Node.js first.
    pause
    exit
)
echo - Tools check: OK.
echo.

:: --- STEP 2: SETUP BACKEND ---
echo [2/5] Setting up Backend (Python)...
cd backend

:: Create virtual environment if it doesn't exist
if not exist .venv (
    echo - Creating virtual environment (.venv)...
    python -m venv .venv
) else (
    echo - Virtual environment already exists.
)

:: Install dependencies
echo - Installing Python dependencies (this may take a few minutes)...
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\pip install -r requirements.txt

:: Create .env file if it doesn't exist
if not exist .env (
    echo - Creating .env file from example...
    copy .env.example .env
) else (
    echo - File .env already exists.
)

:: Go back to root
cd ..
echo - Backend setup: OK.
echo.

:: --- STEP 3: SETUP FRONTEND ---
echo [3/5] Setting up Frontend (Node.js)...
cd frontend

:: Install node_modules
echo - Installing Node.js dependencies (please wait)...
call npm install

:: Go back to root
cd ..
echo - Frontend setup: OK.
echo.

:: --- STEP 4: CHECK FFMPEG ---
echo [4/5] Checking FFmpeg...
where ffmpeg >nul 2>&1
if %errorlevel% neq 0 (
    echo - FFmpeg not found. Attempting automatic installation via Winget...
    winget install Gyan.FFmpeg
    echo Note: If this fails, please install FFmpeg manually.
) else (
    echo - FFmpeg is already installed.
)
echo.

:: --- STEP 5: COMPLETION ---
echo ========================================================
echo                  INSTALLATION COMPLETE!
echo ========================================================
echo.
echo IMPORTANT NEXT STEPS:
echo 1. Open the file "backend/.env" and paste your GEMINI API KEY.
echo 2. Run "Start-App.bat" to launch the application.
echo.
pause