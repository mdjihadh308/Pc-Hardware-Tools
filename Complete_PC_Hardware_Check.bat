@echo off
setlocal EnableExtensions
title Complete PC Hardware Check - Windows 11
color 0A

:MENU
cls
echo ==================================================
echo             WINDOWS 11 HARDWARE CHECK
echo ==================================================
echo.
echo   1: Processor (CPU) Check
echo   2: RAM Check
echo   3: SSD / HDD Health Information
echo   4: GPU Check
echo   5: Motherboard and BIOS Check
echo   6: CPU / GPU Temperature and Fan Information
echo   7: Run ALL Information Checks
echo   8: Windows Memory Diagnostic
echo   0: Exit
echo.
echo ==================================================
set "choice="
set /p "choice=Enter your choice: "

if "%choice%"=="1" goto CPU
if "%choice%"=="2" goto RAM
if "%choice%"=="3" goto DISK
if "%choice%"=="4" goto GPU
if "%choice%"=="5" goto BOARD
if "%choice%"=="6" goto SENSORS
if "%choice%"=="7" goto ALL
if "%choice%"=="8" goto MEMTEST
if "%choice%"=="0" goto END
echo.
echo Invalid choice. Please enter a number from the menu.
pause
goto MENU

:CPU
cls
echo ================ PROCESSOR CHECK ================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Processor | Select-Object Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,CurrentClockSpeed,Status | Format-List"
pause
goto MENU

:RAM
cls
echo ==================== RAM CHECK ===================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator,Manufacturer,@{Name='Capacity_GB';Expression={[math]::Round($_.Capacity/1GB,2)}},Speed,ConfiguredClockSpeed,PartNumber | Format-Table -AutoSize; Get-CimInstance Win32_ComputerSystem | Select-Object @{Name='TotalRAM_GB';Expression={[math]::Round($_.TotalPhysicalMemory/1GB,2)}} | Format-List"
pause
goto MENU

:DISK
cls
echo ================ SSD / HDD CHECK =================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,OperationalStatus,@{Name='Size_GB';Expression={[math]::Round($_.Size/1GB,2)}} -AutoSize"
echo.
echo ============ STORAGE RELIABILITY DATA =============
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | ForEach-Object { Write-Output ('--- ' + $_.FriendlyName + ' ---'); try { Get-StorageReliabilityCounter -PhysicalDisk $_ | Format-List * } catch { Write-Output ('Reliability counters unavailable: ' + $_.Exception.Message) } }"
echo.
echo Note: Not all SSDs/controllers expose reliability counters.
echo HealthStatus Healthy does not guarantee 100%% drive health.
pause
goto MENU

:GPU
cls
echo ==================== GPU CHECK ===================
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,VideoProcessor,DriverVersion,DriverDate,CurrentHorizontalResolution,CurrentVerticalResolution,Status | Format-List"
echo.
where nvidia-smi >nul 2>nul
if not errorlevel 1 (
  echo ============ NVIDIA LIVE INFORMATION ============
  nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.total,memory.used --format=csv
) else (
  echo NVIDIA nvidia-smi utility not found; live NVIDIA metrics unavailable.
)
pause
goto MENU

:BOARD
cls
echo ============ MOTHERBOARD AND BIOS CHECK ==========
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version,Model | Format-List; Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Status | Format-List; Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,SystemType | Format-List"
pause
goto MENU

:SENSORS
cls
echo =========== TEMPERATURE AND FAN SENSORS ===========
echo Windows does not provide universal CPU/GPU temperature
echo or fan RPM readings through standard WMI commands.
echo.
echo If LibreHardwareMonitor is installed and its sensor
echo service/API is available, sensor readings may be queried
echo separately. This menu does not guess missing values.
echo.
echo For accurate readings, check BIOS/UEFI Hardware Monitor
echo or use the PC/motherboard manufacturer's utility.
pause
goto MENU

:ALL
cls
echo ============== ALL HARDWARE INFORMATION ===========
echo.
echo ---------------- PROCESSOR -------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Processor | Select-Object Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,CurrentClockSpeed,Status | Format-List"
echo ---------------- RAM -------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator,Manufacturer,@{Name='Capacity_GB';Expression={[math]::Round($_.Capacity/1GB,2)}},Speed,ConfiguredClockSpeed,PartNumber | Format-Table -AutoSize"
echo ---------------- SSD / HDD ------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,OperationalStatus,@{Name='Size_GB';Expression={[math]::Round($_.Size/1GB,2)}} -AutoSize"
echo ---------------- GPU -------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,Status | Format-List"
echo ---------------- MOTHERBOARD -----------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version | Format-List"
echo ---------------- BIOS ------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Status | Format-List"
echo.
echo Temperature and fan readings are not universally available
echo through built-in Windows commands. See menu option 6.
pause
goto MENU

:MEMTEST
cls
echo ============== WINDOWS MEMORY DIAGNOSTIC ==========
echo Save all open work before continuing.
choice /C YN /N /M "Open Windows Memory Diagnostic? (Y/N): "
if errorlevel 2 goto MENU
start "" mdsched.exe
goto MENU

:END
echo.
echo Exiting Hardware Check.
endlocal
exit /b
