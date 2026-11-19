
@echo off
title MAS Launcher
color 0A

echo ========================================
echo           MAS LAUNCHER
echo ========================================
echo.
echo MAS Launcher চালাতে Y চাপুন।
echo বন্ধ করতে N চাপুন।
echo.

choice /C YN /N /M "আপনার পছন্দ (Y/N): "

if errorlevel 2 goto EXIT
if errorlevel 1 goto RUN

:RUN
echo.
echo MAS Launcher চালু হচ্ছে...
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"
echo.
pause
exit

:EXIT
echo.
echo আপনি MAS Launcher বন্ধ করেছেন।
timeout /t 2 >nul
exit
