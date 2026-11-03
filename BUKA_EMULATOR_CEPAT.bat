@echo off
title Buka KasirPro di Emulator Cepat
color 0B
echo ========================================================
echo         BUKA KASIRPRO INSTAN DI EMULATOR
echo ========================================================
echo.
echo [1/2] Menjalankan Emulator Android hp1...
start "" "C:\android\sdk\emulator\emulator.exe" -avd hp1

echo.
echo [2/2] Menunggu perangkat siap...
"C:\android\sdk\platform-tools\adb.exe" wait-for-device

:WAIT_BOOT
for /f "tokens=*" %%a in ('"C:\android\sdk\platform-tools\adb.exe" shell getprop sys.boot_completed 2^>nul') do set BOOT=%%a
if "%BOOT%"=="1" goto BOOT_DONE
timeout /t 2 /nobreak >nul
goto WAIT_BOOT

:BOOT_DONE
echo Membuka aplikasi KasirPro di layar emulator...
"C:\android\sdk\platform-tools\adb.exe" shell am start -n com.kasirpro.app.kasirpro/com.kasirpro.app.kasirpro.MainActivity
echo.
echo ========================================================
echo  KasirPro berhasil dibuka di jendela HP Android!
echo ========================================================
timeout /t 5

