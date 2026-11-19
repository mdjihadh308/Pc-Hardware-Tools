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
echo   9: Windows Activation Status
echo  10: Save Full System Report to Desktop
echo  11: Disk Cleanup
echo  12: Open Windows Update
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
if "%choice%"=="9" goto ACTIVATION
if "%choice%"=="10" goto REPORT
if "%choice%"=="11" goto CLEANUP
if "%choice%"=="12" goto WINUPDATE
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

:ACTIVATION
cls
echo ============== WINDOWS ACTIVATION STATUS ==========
echo.
echo --- License details ---
cscript //nologo "%windir%\system32\slmgr.vbs" /dli
echo.
echo --- Expiration / activation state ---
cscript //nologo "%windir%\system32\slmgr.vbs" /xpr
echo.
choice /C YN /N /M "Open Settings Activation page? (Y/N): "
if errorlevel 2 goto MENU
start "" ms-settings:activation
goto MENU

:REPORT
cls
echo ============== SAVE FULL SYSTEM REPORT ============
set "DESK="
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
set "REPORT=%DESK%\PC_Hardware_Report.txt"
echo Generating report, please wait...
echo PC HARDWARE REPORT> "%REPORT%"
echo Generated: %DATE% %TIME%>> "%REPORT%"
echo Computer: %COMPUTERNAME%>> "%REPORT%"
echo.>> "%REPORT%"
echo ===== PROCESSOR =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Processor | Select-Object Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,Status | Format-List | Out-String -Width 200" >> "%REPORT%"
echo ===== RAM =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object DeviceLocator,Manufacturer,@{Name='Capacity_GB';Expression={[math]::Round($_.Capacity/1GB,2)}},Speed,PartNumber | Format-Table -AutoSize | Out-String -Width 200" >> "%REPORT%"
echo ===== SSD / HDD =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PhysicalDisk | Format-Table FriendlyName,MediaType,HealthStatus,OperationalStatus,@{Name='Size_GB';Expression={[math]::Round($_.Size/1GB,2)}} -AutoSize | Out-String -Width 200" >> "%REPORT%"
echo ===== GPU =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion,DriverDate,Status | Format-List | Out-String -Width 200" >> "%REPORT%"
echo ===== MOTHERBOARD =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version | Format-List | Out-String -Width 200" >> "%REPORT%"
echo ===== BIOS =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Status | Format-List | Out-String -Width 200" >> "%REPORT%"
echo ===== OPERATING SYSTEM =====>> "%REPORT%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture,InstallDate,LastBootUpTime | Format-List | Out-String -Width 200" >> "%REPORT%"
echo ===== ACTIVATION STATUS =====>> "%REPORT%"
cscript //nologo "%windir%\system32\slmgr.vbs" /xpr >> "%REPORT%"
echo.
echo Report saved to:
echo %REPORT%
choice /C YN /N /M "Open the report now? (Y/N): "
if errorlevel 2 goto MENU
start "" notepad.exe "%REPORT%"
goto MENU

:CLEANUP
cls
echo ==================== DISK CLEANUP =================
echo This opens the built-in Windows Disk Cleanup tool.
echo You choose what to delete inside the tool.
choice /C YN /N /M "Open Disk Cleanup? (Y/N): "
if errorlevel 2 goto MENU
start "" cleanmgr.exe
goto MENU

:WINUPDATE
cls
echo ================== WINDOWS UPDATE ==================
echo Opening Windows Update in Settings...
start "" ms-settings:windowsupdate
timeout /t 2 >nul
goto MENU

:END
echo.
echo Exiting Hardware Check.
endlocal
exit /b
