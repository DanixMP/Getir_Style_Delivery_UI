@echo off
REM ============================================================
REM  GETIR_STYLE_DELIVERY_UI - Backend (Daphne ASGI @ http://127.0.0.1:8000)
REM  HTTP + WebSockets via config.asgi:application
REM ============================================================
setlocal
set "ROOT=%~dp0"
set "BACKEND=%ROOT%getir_style_delivery_ui_backend"
set "VENV=%BACKEND%\.venv\Scripts"
set "PY=%VENV%\python.exe"

if not exist "%PY%" (
    echo [ERROR] Python venv not found at "%BACKEND%\.venv"
    echo Create it first:
    echo     python -m venv "%BACKEND%\.venv"
    echo     "%PY%" -m pip install -r "%BACKEND%\requirements\development.txt"
    pause
    exit /b 1
)

"%PY%" -c "import daphne" 1>nul 2>nul
if errorlevel 1 (
    echo [ERROR] Daphne is not installed in the venv.
    echo Install backend dependencies:
    echo     "%PY%" -m pip install -r "%BACKEND%\requirements\development.txt"
    pause
    exit /b 1
)

set "PATH=%VENV%;%PATH%"
set "DJANGO_SETTINGS_MODULE=config.settings.development"

cd /d "%BACKEND%"
echo Running migrations...
"%PY%" manage.py migrate
if errorlevel 1 (
    echo [ERROR] migrate failed.
    pause
    exit /b 1
)

echo.
echo Starting Daphne ASGI server...
echo   API       : http://127.0.0.1:8000/api/v1/
echo   Admin     : http://127.0.0.1:8000/admin/
echo   WebSocket : ws://127.0.0.1:8000/ws/
echo.
REM Use python -m daphne (venv *.exe launchers can break after folder rename)
"%PY%" -m daphne -b 0.0.0.0 -p 8000 config.asgi:application

endlocal
