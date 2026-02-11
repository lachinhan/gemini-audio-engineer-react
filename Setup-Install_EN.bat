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
)

:: Install dependencies
echo - Installing Python dependencies...
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\pip install -r requirements.txt

:: Create .env file
if not exist .env (
    echo - Creating .env file from example...
    copy .env.example .env
)
echo.

:: --- STEP 2.5: API KEY CONFIGURATION ---
echo --------------------------------------------------------
echo [IMPORTANT] API KEY CONFIGURATION
echo --------------------------------------------------------
echo Please enter your Google Gemini API Key below.
echo (If you don't have it, press Enter to skip and edit manually later)
echo.
set /p API_KEY="> Paste your GEMINI_API_KEY here: "

if "%API_KEY%" neq "" (
    echo.
    echo - Saving API Key to backend/.env...
    :: Use PowerShell to safely replace the placeholder in the .env file
    powershell -Command "(gc .env) -replace 'GEMINI_API_KEY=', 'GEMINI_API_KEY=%API_KEY%' | Set-Content .env"
    echo - API Key saved successfully!
) else (
    echo - Skipped. You must edit backend/.env manually.
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
) else (
    echo - FFmpeg is already installed.
)
echo.

:: --- STEP 5: COMPLETION ---
echo ========================================================
echo                  INSTALLATION COMPLETE!
echo ========================================================
echo.
echo Setup is finished. You can now run "Start-App.bat" to use the tool.
echo.
pause