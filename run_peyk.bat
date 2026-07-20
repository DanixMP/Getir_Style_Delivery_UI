@echo off
REM ============================================================
REM  GetirStyleDeliveryUi - Peyk (courier) app (Flutter web in Chrome @ :5001)
REM ============================================================
setlocal
set "ROOT=%~dp0"
set "PEYK=%ROOT%frontend\getir_style_delivery_ui_peyk"

REM --- Locate Flutter: PATH first, then common install locations ---
set "FLUTTER_BIN="
for /f "delims=" %%i in ('where flutter 2^>nul') do if not defined FLUTTER_BIN set "FLUTTER_BIN=%%~dpi"
if not defined FLUTTER_BIN (
    for /d %%d in ("D:\Program Files\Flutter\*") do if exist "%%d\flutter\bin\flutter.bat" set "FLUTTER_BIN=%%d\flutter\bin"
)
if not defined FLUTTER_BIN if exist "C:\flutter\bin\flutter.bat" set "FLUTTER_BIN=C:\flutter\bin"
if not defined FLUTTER_BIN (
    echo [ERROR] Could not find Flutter. Add Flutter\bin to PATH.
    pause
    exit /b 1
)
set "PATH=%FLUTTER_BIN%;%PATH%"

echo Using Flutter at: %FLUTTER_BIN%
echo Peyk app: http://localhost:5001   (first compile ~30-60s)
echo Make sure the backend is running (run_backend.bat).
cd /d "%PEYK%"
REM web-server avoids Chrome debug-connection failures that cause blank screens.
flutter run -d web-server --web-hostname localhost --web-port 5001

endlocal
