@echo off
title RAM Information and Diagnostic
color 0A

echo ==========================================
echo          RAM INFORMATION CHECK
echo ==========================================
echo.
echo [1] Installed RAM modules
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator,Manufacturer,@{Name='Capacity_GB';Expression={[math]::Round($_.Capacity/1GB,2)}},Speed,ConfiguredClockSpeed,PartNumber | Format-Table -AutoSize"
echo.
echo [2] Total physical memory
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_ComputerSystem | Select-Object @{Name='TotalRAM_GB';Expression={[math]::Round($_.TotalPhysicalMemory/1GB,2)}} | Format-List"
echo.
echo ==========================================
echo [3] Windows Memory Diagnostic
echo This opens the Windows diagnostic tool.
echo It may require a restart to run the test.
echo Save your work before choosing to restart.
echo ==========================================
echo.
choice /C YN /N /M "Open Windows Memory Diagnostic now? (Y/N): "
if errorlevel 2 goto end
if errorlevel 1 start "" mdsched.exe

:end
echo.
echo Finished. RAM information was displayed above.
pause
