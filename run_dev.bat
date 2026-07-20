@echo off
REM ============================================================
REM  GETIR_STYLE_DELIVERY_UI launcher
REM  Starts the Django backend (127.0.0.1:8000) and the Flutter
REM  web app in Chrome, each in its own window.
REM ============================================================

setlocal
set "ROOT=%~dp0"
set "BACKEND=%ROOT%getir_style_delivery_ui_backend"
set "FRONTEND=%ROOT%frontend\getir_style_delivery_ui_v2"
set "PY=%BACKEND%\.venv\Scripts\python.exe"

if not exist "%PY%" (
    echo [ERROR] Python venv not found at "%PY%"
    echo Create it first:
    echo     python -m venv "%BACKEND%\.venv"
    echo     "%PY%" -m pip install -r "%BACKEND%\requirements\development.txt"
    pause
    exit /b 1
)

REM --- Locate Flutter: PATH first, then common install locations ---
set "FLUTTER_BIN="
for /f "delims=" %%i in ('where flutter 2^>nul') do if not defined FLUTTER_BIN set "FLUTTER_BIN=%%~dpi"
if not defined FLUTTER_BIN (
    for /d %%d in ("D:\Program Files\Flutter\*") do if exist "%%d\flutter\bin\flutter.bat" set "FLUTTER_BIN=%%d\flutter\bin"
)
if not defined FLUTTER_BIN if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_BIN=C:\flutter\bin"

if not defined FLUTTER_BIN (
    echo [ERROR] Could not find Flutter. Add Flutter\bin to your PATH,
    echo         or set FLUTTER_BIN manually inside this script.
    pause
    exit /b 1
)

REM Make flutter available to the spawned windows (inherited via the environment).
set "PATH=%FLUTTER_BIN%;%PATH%"
echo Using Flutter at: %FLUTTER_BIN%

echo Starting backend (Daphne ASGI @ http://127.0.0.1:8000) ...
start "GETIR_STYLE_DELIVERY_UI Backend" cmd /k "cd /d %BACKEND% && set DJANGO_SETTINGS_MODULE=config.settings.development && %PY% manage.py migrate && %PY% -m daphne -b 0.0.0.0 -p 8000 config.asgi:application"

REM Give the backend a few seconds before launching the app.
timeout /t 4 /nobreak >nul

echo Starting customer app (Flutter web @ http://localhost:5000) ...
start "GETIR_STYLE_DELIVERY_UI Frontend" cmd /k "cd /d %FRONTEND% && flutter run -d web-server --web-hostname localhost --web-port 5000"

echo.
echo Both processes are launching in separate windows.
echo   Backend : http://127.0.0.1:8000   (admin /admin/, API /api/v1/)
echo   Frontend: http://localhost:5000   (first compile takes ~30s)
echo Press 'q' in the Flutter window (or close the windows) to stop.
endlocal
