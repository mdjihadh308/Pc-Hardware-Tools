@echo off
title GPU Check - Windows 11
color 0A
echo ==========================================
echo              GPU CHECK
echo ==========================================
echo.
echo [1] Graphics adapter information
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,VideoProcessor,DriverVersion,DriverDate,CurrentHorizontalResolution,CurrentVerticalResolution,Status,PNPDeviceID | Format-List"
echo.
echo [2] GPU temperature (NVIDIA only, if nvidia-smi is installed)
where nvidia-smi >nul 2>nul
if %errorlevel%==0 (
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.total,memory.used --format=csv
) else (
    echo nvidia-smi not found. This is normal for many AMD/Intel GPUs
    echo and for NVIDIA systems without the NVIDIA command-line utility.
)
echo.
echo ==========================================
echo Notes:
echo - Windows may not report dedicated VRAM correctly for every GPU.
echo - GPU temperature is not universally available through CMD/WMI.
echo - This is an information check, not a GPU stress test.
echo ==========================================
echo.
pause
