@echo off
title CPU Information and Diagnostic
color 0A

echo ==========================================
echo       PROCESSOR / CPU INFORMATION
echo ==========================================
echo.
echo [1] CPU model and core information
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Processor | Select-Object Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,CurrentClockSpeed,ProcessorId | Format-List"
echo.
echo [2] CPU usage (live sample)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Counter '\Processor(_Total)\%% Processor Time' -SampleInterval 1 -MaxSamples 3 | Select-Object -ExpandProperty CounterSamples | Select-Object @{Name='CPU_Usage_Percent';Expression={[math]::Round($_.CookedValue,1)}} | Format-Table -AutoSize"
echo.
echo [3] Windows processor architecture
echo %PROCESSOR_ARCHITECTURE%
echo.
echo ==========================================
echo Notes:
echo This script reports CPU details and a short usage sample.
echo It does NOT stress-test the CPU or prove hardware stability.
echo For temperature, use your PC/motherboard manufacturer's
echo monitoring utility; Windows may not expose CPU temperature.
echo ==========================================
echo.
pause
