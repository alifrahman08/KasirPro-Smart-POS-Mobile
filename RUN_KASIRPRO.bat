@echo off
title KasirPro - Smart POS Mobile Launcher
color 0A
echo ========================================================
echo         KASIRPRO - SMART POS MOBILE LAUNCHER
echo ========================================================
echo.
echo [1/3] Menjalankan Android Emulator (hp1)...
echo Jendela HP Android akan segera muncul di layar Anda.
start "" "C:\android\sdk\emulator\emulator.exe" -avd hp1

echo.
echo [2/3] Menunggu Android Emulator siap...
"C:\android\sdk\platform-tools\adb.exe" wait-for-device
echo Emulator terdeteksi! Menunggu sistem booting...

:WAIT_BOOT
for /f "tokens=*" %%a in ('"C:\android\sdk\platform-tools\adb.exe" shell getprop sys.boot_completed 2^>nul') do set BOOT=%%a
if "%BOOT%"=="1" goto BOOT_DONE
timeout /t 2 /nobreak >nul
goto WAIT_BOOT

:BOOT_DONE
echo.
echo [3/3] Emulator siap! Memulai KasirPro dengan Flutter Hot Reload...
echo Tekan 'r' untuk Hot Reload, 'R' untuk Hot Restart, 'q' untuk keluar.
echo ========================================================
echo.
"C:\Users\ADMIN\fvm\default\bin\flutter.bat" run -d emulator-5554

pause

