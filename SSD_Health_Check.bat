@echo off
title SSD Health Check
color 0A

echo ==========================================
echo          SSD / DISK HEALTH CHECK
echo ==========================================
echo.
echo Checking physical disks...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,OperationalStatus,Size -AutoSize"

echo.
echo ==========================================
echo Check completed.
echo Note: Healthy does not guarantee 100%% SSD health.
echo Some SSDs may not report all health information.
echo ==========================================
echo.
pause
