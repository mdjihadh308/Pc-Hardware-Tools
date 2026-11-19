@echo off
title Motherboard Check - Windows 11
color 0A
echo ==========================================
echo          MOTHERBOARD CHECK
echo ==========================================
echo.
echo [1] Motherboard information
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version,Model | Format-List"
echo.
echo [2] BIOS information
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Status | Format-List"
echo.
echo [3] Computer model
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,SystemType | Format-List"
echo.
echo [4] Motherboard and sensor note
echo Windows does not expose motherboard temperature or fan RPM
echo consistently on all PCs. Use the motherboard maker's utility
echo or BIOS/UEFI Hardware Monitor for those readings.
echo.
echo ==========================================
echo This script reads system information only.
echo It does not change BIOS or motherboard settings.
echo ==========================================
echo.
pause
