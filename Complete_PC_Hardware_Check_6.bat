@echo off
setlocal EnableExtensions
title Complete PC Hardware Check PRO - Windows 11
color 0A
set "PS=powershell -NoProfile -ExecutionPolicy Bypass -Command"

rem ---- Detect Administrator rights ----
set "ISADMIN=0"
fltmc >nul 2>&1 && set "ISADMIN=1"

:MENU
cls
echo ====================================================================
echo        WINDOWS 7/8/10/11 HARDWARE CHECK  -  CREATED BY JIHAD
echo ====================================================================
if "%ISADMIN%"=="1" (echo   Mode: ADMINISTRATOR - all checks available) else (echo   Mode: Standard user - some checks need Administrator, press A)
echo ----------------------------------------------------------
echo   HARDWARE INFORMATION
echo    1: Processor (CPU) - cache, socket, virtualization, load
echo    2: RAM - brand, part number, type DDR, speed, slots
echo    3: Storage - model, serial, wear, hours, free space
echo    4: GPU - VRAM, driver, refresh rate, live NVIDIA data
echo    5: Motherboard / BIOS / UEFI / Secure Boot / TPM
echo    6: Temperatures and Fans
echo    7: Battery - health and wear (laptops)
echo    8: Network CENTER - Wi-Fi passwords, speed test, IP, ports...
echo    9: Display / Monitors
echo   10: Operating System and Uptime
echo   11: Live Performance (CPU, RAM, disk, top processes)
echo   12: Run ALL information checks
echo ----------------------------------------------------------
echo   DIAGNOSTICS
echo   13: Windows 11 Compatibility Check
echo   14: Startup Programs
echo   15: Problem Devices / Driver Errors
echo   16: Recent System Errors (last 3 days)
echo   17: Installed Software List
echo   18: System Health Tools (SFC / DISM / CHKDSK / WinSAT)
echo   19: Windows Memory Diagnostic
echo   20: Windows Activation Status
echo ----------------------------------------------------------
echo   TOOLS
echo   21: Save Full System Report to Desktop
echo   22: Disk Cleanup
echo   23: Open Windows Update
echo   24: Quick Tools (Task Manager, Device Manager, DxDiag...)
echo   25: WINDOWS ACTIVATION LAUNCHER
echo   26: PENDRIVE - Show Hidden Files (asks drive letter)
echo    A: Restart this tool as Administrator
echo    0: Exit
echo ==========================================================
set "choice="
set /p "choice=Enter your choice: "
set "choice=%choice: =%"

if /i "%choice%"=="1"  goto M1
if /i "%choice%"=="2"  goto M2
if /i "%choice%"=="3"  goto M3
if /i "%choice%"=="4"  goto M4
if /i "%choice%"=="5"  goto M5
if /i "%choice%"=="6"  goto M6
if /i "%choice%"=="7"  goto M7
if /i "%choice%"=="8"  goto M8
if /i "%choice%"=="9"  goto M9
if /i "%choice%"=="10" goto M10
if /i "%choice%"=="11" goto M11
if /i "%choice%"=="12" goto M12
if /i "%choice%"=="13" goto M13
if /i "%choice%"=="14" goto M14
if /i "%choice%"=="15" goto M15
if /i "%choice%"=="16" goto M16
if /i "%choice%"=="17" goto M17
if /i "%choice%"=="18" goto HEALTH
if /i "%choice%"=="19" goto MEMTEST
if /i "%choice%"=="20" goto ACTIVATION
if /i "%choice%"=="21" goto REPORT
if /i "%choice%"=="22" goto CLEANUP
if /i "%choice%"=="23" goto WINUPDATE
if /i "%choice%"=="24" goto TOOLS
if /i "%choice%"=="25" goto MAS_LAUNCHER_MENU
if /i "%choice%"=="26" goto UNHIDE
if /i "%choice%"=="A"  goto ELEVATE
if /i "%choice%"=="0"  goto END
echo.
echo Invalid choice. Please enter a number from the menu.
pause
goto MENU

rem =====================================================
rem  MENU ENTRIES
rem =====================================================
:M1
cls
call :S_CPU
pause
goto MENU

:M2
cls
call :S_RAM
pause
goto MENU

:M3
cls
call :S_DISK
echo.
echo Note: Not all SSDs/controllers expose reliability counters.
echo HealthStatus Healthy does not guarantee 100%% drive health.
pause
goto MENU

:M4
cls
call :S_GPU
pause
goto MENU

:M5
cls
call :S_BOARD
pause
goto MENU

:M6
cls
call :S_SENSORS
pause
goto MENU

:M7
cls
call :S_BATTERY
echo.
choice /C YN /N /M "Generate full Windows battery report on Desktop? (Y/N): "
if errorlevel 2 goto MENU
set "DESK="
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
powercfg /batteryreport /output "%DESK%\Battery_Report.html"
if exist "%DESK%\Battery_Report.html" start "" "%DESK%\Battery_Report.html"
pause
goto MENU

:M8
goto NETMENU

:M9
cls
call :S_DISPLAY
pause
goto MENU

:M10
cls
call :S_OS
pause
goto MENU

:M11
cls
call :S_PERF
pause
goto MENU

:M12
cls
call :S_OS
call :S_CPU
call :S_RAM
call :S_DISK
call :S_GPU
call :S_BOARD
call :S_DISPLAY
call :S_NET
call :HDR "NETWORK OVERVIEW"
%PS% "Get-NetAdapter | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MediaType,MacAddress,DriverVersion,@{N='MTU';E={$_.MtuSize}} | Format-List | Out-String -Width 200; Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | ForEach-Object { [pscustomobject]@{Adapter=$_.Description;MAC=$_.MACAddress;IPAddresses=($_.IPAddress -join ', ');SubnetMask=($_.IPSubnet -join ', ');Gateway=($_.DefaultIPGateway -join ', ');DHCP_Enabled=$_.DHCPEnabled;DHCP_Server=$_.DHCPServer;LeaseObtained=$_.DHCPLeaseObtained;LeaseExpires=$_.DHCPLeaseExpires;DNS_Servers=($_.DNSServerSearchOrder -join ', ');DNS_Domain=$_.DNSDomain} | Format-List | Out-String -Width 200 }; 'Computer name: '+$env:COMPUTERNAME; 'Internet test (8.8.8.8): '+$(if(Test-Connection 8.8.8.8 -Count 2 -Quiet){'ONLINE'}else{'NO RESPONSE'})"
call :S_WIFICUR
exit /b

:S_WIFICUR
call :HDR "CURRENT WI-FI CONNECTION"
netsh wlan show interfaces 2>nul
exit /b

:S_WIFICURPW
echo.
echo ====================================================================
echo ============ PASSWORD OF CONNECTED WI-FI ============
echo ====================================================================
%PS% "$s=netsh wlan show interfaces | Select-String '^\s*SSID\s*:' | Select-Object -First 1; if(-not $s){'Not connected to Wi-Fi.'; exit}; $n=($s.Line -split ':',2)[1].Trim(); $k=netsh wlan show profile name=$n key=clear; $pw=$k | Select-String 'Key Content'; 'Wi-Fi name (SSID): '+$n; 'Password         : '+$(if($pw){($pw.Line -split ':',2)[1].Trim()}else{'not available - run as Administrator (press A in main menu)'})"
exit /b

:S_WIFIPASS
call :HDR "SAVED WI-FI PROFILES AND PASSWORDS"
%PS% "$out=netsh wlan show profiles | Select-String 'All User Profile'; if(-not $out){'No saved Wi-Fi profiles found.'; exit}; $out | ForEach-Object { $n=($_.Line -split ':',2)[1].Trim(); $k=netsh wlan show profile name=$n key=clear; $pw=($k | Select-String 'Key Content'); $au=($k | Select-String 'Authentication' | Select-Object -First 1); [pscustomobject]@{SSID=$n;Security=$(if($au){($au.Line -split ':',2)[1].Trim()}else{'?'});Password=$(if($pw){($pw.Line -split ':',2)[1].Trim()}else{'(none / open / enterprise)'})} } | Format-Table -AutoSize | Out-String -Width 200"
exit /b

:S_WIFISCAN
call :HDR "NEARBY WI-FI NETWORKS"
netsh wlan show networks mode=bssid 2>nul
exit /b

:S_PUBLIC
call :HDR "PUBLIC IP AND ISP"
%PS% "try{ $r=Invoke-RestMethod 'https://ipinfo.io/json' -TimeoutSec 8; [pscustomobject]@{PublicIP=$r.ip;Hostname=$r.hostname;ISP_Org=$r.org;City=$r.city;Region=$r.region;Country=$r.country;Location=$r.loc;Timezone=$r.timezone} | Format-List | Out-String }catch{ 'Could not reach the internet to look up public IP.' }"
exit /b

:S_PING
call :HDR "PING / LATENCY / DNS TEST"
%PS% "$gw=(Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1).IPv4DefaultGateway.NextHop; $targets=@($gw,'8.8.8.8','1.1.1.1','google.com') | Where-Object {$_}; foreach($h in $targets){ $r=@(Test-Connection $h -Count 4 -ErrorAction SilentlyContinue); if($r.Count -gt 0){ $a=$r | Measure-Object ResponseTime -Average -Minimum -Maximum; '{0,-16} OK     avg {1} ms   min {2}   max {3}   lost {4} of 4' -f $h,[math]::Round($a.Average,0),$a.Minimum,$a.Maximum,(4-$r.Count) }else{ '{0,-16} FAILED (no reply)' -f $h } }; $ms=(Measure-Command{Resolve-DnsName google.com -ErrorAction SilentlyContinue}).TotalMilliseconds; ''; 'DNS lookup time for google.com: '+[math]::Round($ms)+' ms'"
exit /b

:S_SPEED
call :HDR "INTERNET DOWNLOAD SPEED TEST"
echo Downloading test data, please wait...
%PS% "try{ $sw=[Diagnostics.Stopwatch]::StartNew(); $wc=New-Object Net.WebClient; $d=$wc.DownloadData('https://speed.cloudflare.com/__down?bytes=25000000'); $sw.Stop(); 'Downloaded : '+[math]::Round($d.Length/1MB,1)+' MB in '+[math]::Round($sw.Elapsed.TotalSeconds,1)+' s'; 'Speed      : '+[math]::Round($d.Length*8/1000000/$sw.Elapsed.TotalSeconds,1)+' Mbps (single connection, approximate)' }catch{ 'Speed test failed - check internet connection.' }"
exit /b

:S_CONNS
call :HDR "ACTIVE CONNECTIONS"
%PS% "Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,@{N='Program';E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} | Sort-Object Program | Format-Table -AutoSize | Out-String -Width 200"
exit /b

:S_ARP
call :HDR "DEVICES ON LOCAL NETWORK"
%PS% "Get-NetNeighbor -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {$_.State -ne 'Unreachable' -and $_.LinkLayerAddress -and $_.LinkLayerAddress -ne 'FF-FF-FF-FF-FF-FF' -and $_.IPAddress -notlike '224.*' -and $_.IPAddress -notlike '239.*'} | Select-Object IPAddress,LinkLayerAddress,State,InterfaceAlias | Sort-Object IPAddress | Format-Table -AutoSize | Out-String -Width 200"
echo Only devices recently contacted are shown. Ping the router first for a fuller list.
exit /b

:S_FIREWALL
call :HDR "FIREWALL AND LISTENING PORTS"
%PS% "Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Format-Table -AutoSize | Out-String; 'Listening TCP ports:'; Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress,LocalPort,@{N='Program';E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} | Sort-Object LocalPort | Format-Table -AutoSize | Out-String -Width 200"
exit /b

:S_DISPLAY
pause
goto MENU

:M10
cls
call :S_OS
pause
goto MENU

:M11
cls
call :S_PERF
pause
goto MENU

:M12
cls
call :S_OS
call :S_CPU
call :S_RAM
call :S_DISK
call :S_GPU
call :S_BOARD
call :S_DISPLAY
call :S_NET
call :S_BATTERY
call :S_SENSORS
pause
goto MENU

:M13
cls
call :S_WIN11
pause
goto MENU

:M14
cls
call :S_STARTUP
pause
goto MENU

:M15
cls
call :S_PROBLEMS
pause
goto MENU

:M16
cls
call :S_EVENTS
pause
goto MENU

:M17
cls
call :S_SOFTWARE
pause
goto MENU


rem =====================================================
rem  NETWORK CENTER SUBMENU
rem =====================================================
:NETMENU
cls
echo ====================================================================
echo ================== NETWORK CENTER ===================
echo ====================================================================
echo   1: Network overview (adapters, IP, DHCP, DNS, MTU)
echo   2: Current Wi-Fi details + its PASSWORD
echo   3: Saved Wi-Fi passwords (own PC, needs Administrator)
echo   4: Nearby Wi-Fi networks
echo   5: Public IP and ISP information
echo   6: Ping / latency / DNS test
echo   7: Internet download speed test (uses about 25 MB)
echo   8: Active connections with program names
echo   9: Devices on local network (ARP table)
echo  10: Firewall status and listening ports
echo  11: Flush DNS / Release and Renew IP (needs Administrator)
echo   0: Back
echo ====================================================
set "nc="
set /p "nc=Choice: "
if "%nc%"=="0"  goto MENU
if "%nc%"=="1"  ( cls & call :S_NET & pause & goto NETMENU )
if "%nc%"=="2"  ( cls & call :S_WIFICUR & call :S_WIFICURPW & pause & goto NETMENU )
if "%nc%"=="3"  goto NET_PASS
if "%nc%"=="4"  ( cls & call :S_WIFISCAN & pause & goto NETMENU )
if "%nc%"=="5"  ( cls & call :S_PUBLIC & pause & goto NETMENU )
if "%nc%"=="6"  ( cls & call :S_PING & pause & goto NETMENU )
if "%nc%"=="7"  ( cls & call :S_SPEED & pause & goto NETMENU )
if "%nc%"=="8"  ( cls & call :S_CONNS & pause & goto NETMENU )
if "%nc%"=="9"  ( cls & call :S_ARP & pause & goto NETMENU )
if "%nc%"=="10" ( cls & call :S_FIREWALL & pause & goto NETMENU )
if "%nc%"=="11" goto NET_RESET
goto NETMENU

:NET_PASS
cls
echo ====================================================================
echo ============ SAVED WI-FI PASSWORDS ============
echo ====================================================================
echo Shows passwords of Wi-Fi networks saved on THIS PC.
echo Use only on your own computer. Do not share the output.
if not "%ISADMIN%"=="1" (
  echo.
  echo Administrator rights are required. Return to main menu and press A.
  pause
  goto NETMENU
)
choice /C YN /N /M "Show saved Wi-Fi passwords now? (Y/N): "
if errorlevel 2 goto NETMENU
call :S_WIFIPASS
echo.
choice /C YN /N /M "Save this list to a text file on Desktop? (Y/N): "
if errorlevel 2 goto NETMENU
set "DESK="
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
call :S_WIFIPASS > "%DESK%\WiFi_Passwords.txt" 2>&1
echo Saved: %DESK%\WiFi_Passwords.txt  (keep it private, delete when done)
pause
goto NETMENU

:NET_RESET
cls
echo ====================================================================
echo ============ FLUSH DNS / RENEW IP ============
echo ====================================================================
if not "%ISADMIN%"=="1" (
  echo Administrator rights are required. Return to main menu and press A.
  pause
  goto NETMENU
)
echo Flushing DNS cache...
ipconfig /flushdns
choice /C YN /N /M "Also release and renew IP? Connection drops briefly. (Y/N): "
if errorlevel 2 goto NET_RESET_END
ipconfig /release
ipconfig /renew
:NET_RESET_END
pause
goto NETMENU

rem =====================================================
rem  SYSTEM HEALTH SUBMENU
rem =====================================================
:HEALTH
cls
echo ====================================================================
echo ================ SYSTEM HEALTH TOOLS =================
echo ====================================================================
if not "%ISADMIN%"=="1" echo   WARNING: Not running as Administrator. Press A in main menu.
echo.
echo   1: SFC  - Scan and repair system files
echo   2: DISM - Quick CheckHealth
echo   3: DISM - ScanHealth (deeper, takes a few minutes)
echo   4: DISM - RestoreHealth (repairs Windows image, needs internet)
echo   5: CHKDSK - Read-only online scan of C:
echo   6: WinSAT - Disk speed benchmark
echo   0: Back
echo.
set "hc="
set /p "hc=Choice: "
if "%hc%"=="0" goto MENU
if not "%ISADMIN%"=="1" (
  echo.
  echo These tools require Administrator. Return and press A.
  pause
  goto HEALTH
)
if "%hc%"=="1" sfc /scannow
if "%hc%"=="2" DISM /Online /Cleanup-Image /CheckHealth
if "%hc%"=="3" DISM /Online /Cleanup-Image /ScanHealth
if "%hc%"=="4" DISM /Online /Cleanup-Image /RestoreHealth
if "%hc%"=="5" chkdsk C: /scan
if "%hc%"=="6" winsat disk -drive c
pause
goto HEALTH

:MEMTEST
cls
echo ====================================================================
echo ============== WINDOWS MEMORY DIAGNOSTIC ==========
echo ====================================================================
echo Save all open work before continuing.
echo The PC will restart to run the test.
choice /C YN /N /M "Open Windows Memory Diagnostic? (Y/N): "
if errorlevel 2 goto MENU
start "" mdsched.exe
goto MENU

:ACTIVATION
cls
echo ====================================================================
echo ============== WINDOWS ACTIVATION STATUS ==========
echo ====================================================================
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
echo ====================================================================
echo ============== SAVE FULL SYSTEM REPORT ============
echo ====================================================================
set "DESK="
set "STAMP="
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "DESK=%%D"
for /f "delims=" %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%T"
if not defined DESK set "DESK=%USERPROFILE%\Desktop"
set "REPORT=%DESK%\PC_Hardware_Report_%STAMP%.txt"
echo Generating report, this can take up to a minute...
(
  echo PC HARDWARE REPORT
  echo Generated: %DATE% %TIME%
  echo Computer: %COMPUTERNAME%
  echo Administrator mode: %ISADMIN%
  call :S_OS
  call :S_CPU
  call :S_RAM
  call :S_DISK
  call :S_GPU
  call :S_BOARD
  call :S_DISPLAY
  call :S_NET
  call :S_BATTERY
  call :S_SENSORS
  call :S_WIN11
  call :S_STARTUP
  call :S_PROBLEMS
  call :S_EVENTS
  echo.
echo ====================================================================
  echo ============ ACTIVATION STATUS ============
echo ====================================================================
  cscript //nologo "%windir%\system32\slmgr.vbs" /xpr
) > "%REPORT%" 2>&1
echo.
echo Report saved to:
echo %REPORT%
choice /C YN /N /M "Open the report now? (Y/N): "
if errorlevel 2 goto MENU
start "" notepad.exe "%REPORT%"
goto MENU

:CLEANUP
cls
echo ====================================================================
echo ==================== DISK CLEANUP =================
echo ====================================================================
echo This opens the built-in Windows Disk Cleanup tool.
echo You choose what to delete inside the tool.
choice /C YN /N /M "Open Disk Cleanup? (Y/N): "
if errorlevel 2 goto MENU
start "" cleanmgr.exe
goto MENU

:WINUPDATE
cls
echo ====================================================================
echo ================== WINDOWS UPDATE ==================
echo ====================================================================
echo Opening Windows Update in Settings...
start "" ms-settings:windowsupdate
timeout /t 2 >nul
goto MENU

:TOOLS
cls
echo ====================================================================
echo ==================== QUICK TOOLS ===================
echo ====================================================================
echo   1: Task Manager
echo   2: Device Manager
echo   3: Disk Management
echo   4: System Information (msinfo32)
echo   5: DirectX Diagnostic (dxdiag)
echo   6: Resource Monitor
echo   7: Windows Security
echo   8: Storage Settings
echo   0: Back
echo.
set "tc="
set /p "tc=Choice: "
if "%tc%"=="0" goto MENU
if "%tc%"=="1" start "" taskmgr.exe
if "%tc%"=="2" start "" devmgmt.msc
if "%tc%"=="3" start "" diskmgmt.msc
if "%tc%"=="4" start "" msinfo32.exe
if "%tc%"=="5" start "" dxdiag.exe
if "%tc%"=="6" start "" resmon.exe
if "%tc%"=="7" start "" windowsdefender:
if "%tc%"=="8" start "" ms-settings:storagesense
goto TOOLS

rem =====================================================
rem           WINDOWS ACTIVATION LAUNCHER
rem =====================================================

:MAS_LAUNCHER_MENU
cls
title MAS Launcher
color 0A

echo ================================================
echo           WINDOWS ACTIVATION LAUNCHER
echo ================================================
echo.
echo Press Y to launch MAS Launcher.
echo Press N to return to the Main Menu.
echo.

choice /C YN /N /M "Your choice (Y/N): "

if errorlevel 2 goto MENU
if errorlevel 1 goto MAS_LAUNCHER_RUN

:MAS_LAUNCHER_RUN
cls
echo =======================================================
echo          STARTING WINDOWS ACTIVATION LAUNCHER
echo =======================================================
echo.
echo Connecting to MAS Launcher...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"

echo.
echo MAS Launcher process finished.
pause

goto MENU


rem =====================================================
rem           PENDRIVE - SHOW HIDDEN FILES
rem =====================================================

:UNHIDE
cls
echo ====================================================================
echo           PENDRIVE / DRIVE - SHOW HIDDEN FILES
echo ====================================================================
echo.
echo Drives found on this PC:
%PS% "Get-Volume | Where-Object {$_.DriveLetter} | Select-Object @{N='Drive';E={$_.DriveLetter+':'}},FileSystemLabel,FileSystem,DriveType,@{N='SizeGB';E={[math]::Round($_.Size/1GB,2)}} | Format-Table -AutoSize | Out-String"

:UNHIDE_ASK
set "DL="
set /p "DL=Enter pendrive DRIVE LETTER (example E)  [0 = back to menu]: "
if not defined DL goto UNHIDE_ASK
set "DL=%DL: =%"
set "DL=%DL::=%"
set "DL=%DL:\=%"
if not defined DL goto UNHIDE_ASK
if "%DL%"=="0" goto MENU
set "DL=%DL:~0,1%"
if not exist "%DL%:\" (
  echo.
  echo Drive %DL%: not found. Please check the list above and try again.
  echo.
  goto UNHIDE_ASK
)

echo.
if /i "%DL%"=="%SystemDrive:~0,1%" (
  echo WARNING: %DL%: is your Windows system drive, not a pendrive.
  echo Running on it can take a very long time.
  echo.
)
echo Selected drive: %DL%:
echo Command: attrib -h -r -s /s /d %DL%:\*.*
echo.
choice /C YN /N /M "Continue? (Y/N): "
if errorlevel 2 goto MENU

echo.
echo Removing hidden / read-only / system attributes on %DL%: ... please wait.
attrib -h -r -s /s /d "%DL%:\*.*"
echo.
echo Done! Opening %DL%: now - check your files.
start "" "%DL%:\"
pause
goto MENU


:ELEVATE
if "%ISADMIN%"=="1" (
  echo Already running as Administrator.
  pause
  goto MENU
)
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b

:END
echo.
echo Exiting Hardware Check.
endlocal
exit /b

rem =====================================================
rem  SUBROUTINES (information sections)
rem =====================================================
:HDR
echo.
echo ==================== %~1 ====================
echo.
exit /b

:S_OS
call :HDR "OPERATING SYSTEM"
%PS% "$o=Get-CimInstance Win32_OperatingSystem; $c=Get-CimInstance Win32_ComputerSystem; [pscustomobject]@{Computer=$o.CSName;Windows=$o.Caption;Version=$o.Version;Build=$o.BuildNumber;Architecture=$o.OSArchitecture;InstallDate=$o.InstallDate;LastBoot=$o.LastBootUpTime;Uptime=((Get-Date)-$o.LastBootUpTime).ToString('d\.hh\:mm\:ss');User=$c.UserName;Domain=$c.Domain;SystemType=$c.SystemType;Language=$o.MUILanguages -join ', ';Windows_Folder=$o.WindowsDirectory} | Format-List | Out-String -Width 200; Get-CimInstance Win32_PageFileUsage | Select-Object Name,AllocatedBaseSize,CurrentUsage,PeakUsage | Format-Table -AutoSize | Out-String -Width 200"
exit /b

:S_CPU
call :HDR "PROCESSOR (CPU)"
%PS% "foreach($p in Get-CimInstance Win32_Processor){ [pscustomobject]@{Name=$p.Name.Trim();Manufacturer=$p.Manufacturer;Socket=$p.SocketDesignation;Cores=$p.NumberOfCores;LogicalProcessors=$p.NumberOfLogicalProcessors;BaseSpeed_MHz=$p.MaxClockSpeed;CurrentSpeed_MHz=$p.CurrentClockSpeed;L2_Cache_MB=[math]::Round($p.L2CacheSize/1024,2);L3_Cache_MB=[math]::Round($p.L3CacheSize/1024,2);Architecture=@{0='x86';5='ARM';9='x64';12='ARM64'}[[int]$p.Architecture];Family=$p.Caption;VirtualizationEnabled=$p.VirtualizationFirmwareEnabled;SLAT_Support=$p.SecondLevelAddressTranslationExtensions;CurrentLoad_Percent=$p.LoadPercentage;Voltage=$p.CurrentVoltage;ProcessorId=$p.ProcessorId;Status=$p.Status} | Format-List | Out-String -Width 200 }"
exit /b

:S_RAM
call :HDR "RAM (MEMORY)"
%PS% "$t=@{18='DDR';19='DDR2';24='DDR3';26='DDR4';27='LPDDR';28='LPDDR2';29='LPDDR3';30='LPDDR4';34='DDR5';35='LPDDR5'}; $f=@{8='DIMM';12='SODIMM';13='SRIMM';11='RIMM';6='Proprietary';0='Unknown'}; Get-CimInstance Win32_PhysicalMemory | ForEach-Object { [pscustomobject]@{Slot=$_.DeviceLocator;Bank=$_.BankLabel;Brand=$_.Manufacturer;PartNumber=([string]$_.PartNumber).Trim();SerialNumber=([string]$_.SerialNumber).Trim();Capacity_GB=[math]::Round($_.Capacity/1GB,2);Type=$(if($t[[int]$_.SMBIOSMemoryType]){$t[[int]$_.SMBIOSMemoryType]}else{'Unknown'});FormFactor=$f[[int]$_.FormFactor];Rated_MHz=$_.Speed;Running_MHz=$_.ConfiguredClockSpeed;Voltage_V=$(if($_.ConfiguredVoltage){$_.ConfiguredVoltage/1000}else{'n/a'})} | Format-List | Out-String -Width 200 }"
%PS% "$a=Get-CimInstance Win32_PhysicalMemoryArray; $used=@(Get-CimInstance Win32_PhysicalMemory).Count; $slots=($a | Measure-Object MemoryDevices -Sum).Sum; 'Slots used / total : '+$used+' / '+$slots; 'Max supported RAM  : '+[math]::Round(($a | Measure-Object MaxCapacity -Sum).Sum/1MB,0)+' GB'; $o=Get-CimInstance Win32_OperatingSystem; $tot=$o.TotalVisibleMemorySize/1MB; $fr=$o.FreePhysicalMemory/1MB; 'Total usable RAM   : '+[math]::Round($tot,2)+' GB'; 'In use now         : '+[math]::Round($tot-$fr,2)+' GB'; 'Free now           : '+[math]::Round($fr,2)+' GB'; 'Usage              : '+[math]::Round(100*($tot-$fr)/$tot,1)+' percent'; if($used -ge 2){'Channel hint        : '+$used+' sticks installed (dual-channel possible if placed in correct slots)'}"
exit /b

:S_DISK
call :HDR "STORAGE (SSD / HDD)"
%PS% "Get-PhysicalDisk | ForEach-Object { $d=$_; $r=$d | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue; [pscustomobject]@{Name=$d.FriendlyName;Model=$d.Model;Serial=([string]$d.SerialNumber).Trim();Firmware=$d.FirmwareVersion;MediaType=$d.MediaType;BusType=$d.BusType;Size_GB=[math]::Round($d.Size/1GB,1);HealthStatus=$d.HealthStatus;Operational=$d.OperationalStatus;Temp_C=$r.Temperature;MaxTemp_C=$r.TemperatureMax;Wear_Percent=$r.Wear;PowerOnHours=$r.PowerOnHours;StartStopCycles=$r.StartStopCycleCount;ReadErrors=$r.ReadErrorsTotal;WriteErrors=$r.WriteErrorsTotal} | Format-List | Out-String -Width 200 }"
echo --- Partition style / boot disk ---
%PS% "Get-Disk | Select-Object Number,FriendlyName,PartitionStyle,IsBoot,IsSystem,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}} | Format-Table -AutoSize | Out-String -Width 200"
echo --- Volumes and free space ---
%PS% "Get-Volume | Where-Object {$_.DriveLetter} | Select-Object DriveLetter,FileSystemLabel,FileSystem,HealthStatus,@{N='Size_GB';E={[math]::Round($_.Size/1GB,1)}},@{N='Free_GB';E={[math]::Round($_.SizeRemaining/1GB,1)}},@{N='Free_Percent';E={if($_.Size){[math]::Round(100*$_.SizeRemaining/$_.Size,1)}}} | Format-Table -AutoSize | Out-String -Width 200"
echo --- SMART failure prediction ---
%PS% "try{ Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction Stop | Select-Object InstanceName,PredictFailure,Reason | Format-Table -AutoSize | Out-String -Width 200 }catch{ 'SMART failure prediction unavailable (needs Administrator or unsupported by drive).' }"
exit /b

:S_GPU
call :HDR "GPU (GRAPHICS)"
%PS% "Get-CimInstance Win32_VideoController | Select-Object Name,AdapterCompatibility,VideoProcessor,DriverVersion,DriverDate,VideoModeDescription,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate,Status | Format-List | Out-String -Width 200"
echo --- Dedicated video memory (from registry, accurate above 4 GB) ---
%PS% "Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11cd-b05c-0008a4ba0eac}\0*' -ErrorAction SilentlyContinue | Where-Object {$_.'HardwareInformation.qwMemorySize'} | ForEach-Object { $_.DriverDesc+' : '+[math]::Round($_.'HardwareInformation.qwMemorySize'/1GB,2)+' GB' }"
echo.
where nvidia-smi >nul 2>nul
if errorlevel 1 goto GPU_NONV
echo ====================================================================
echo ============ NVIDIA LIVE INFORMATION ============
echo ====================================================================
nvidia-smi --query-gpu=name,driver_version,temperature.gpu,fan.speed,utilization.gpu,memory.total,memory.used,power.draw,clocks.gr,clocks.mem --format=csv
exit /b
:GPU_NONV
echo NVIDIA nvidia-smi utility not found; live NVIDIA metrics unavailable.
exit /b

:S_BOARD
call :HDR "MOTHERBOARD / BIOS / SECURITY"
%PS% "Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer,Model,SystemFamily,SystemSKUNumber,SystemType | Format-List | Out-String -Width 200; Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer,Product,Version,SerialNumber | Format-List | Out-String -Width 200; Get-CimInstance Win32_BIOS | Select-Object Manufacturer,SMBIOSBIOSVersion,ReleaseDate,SerialNumber,Status | Format-List | Out-String -Width 200; Get-CimInstance Win32_SystemEnclosure | Select-Object @{N='ChassisType';E={$_.ChassisTypes -join ','}},SerialNumber,SMBIOSAssetTag | Format-List | Out-String -Width 200"
echo --- Firmware and security ---
%PS% "if(Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'){'Boot mode   : UEFI'}else{'Boot mode   : Legacy BIOS'}; try{'Secure Boot : '+$(if(Confirm-SecureBootUEFI){'Enabled'}else{'Disabled'})}catch{'Secure Boot : Not available or needs Administrator'}; try{$t=Get-CimInstance -Namespace root\cimv2\Security\MicrosoftTpm -ClassName Win32_Tpm -ErrorAction Stop; 'TPM         : Present, spec '+$t.SpecVersion+', enabled '+$t.IsEnabled_InitialValue}catch{'TPM         : Not detected or needs Administrator'}; 'Virtualization firmware enabled: '+(Get-CimInstance Win32_Processor | Select-Object -First 1).VirtualizationFirmwareEnabled"
exit /b

:S_SENSORS
call :HDR "TEMPERATURES AND FANS"
echo --- ACPI thermal zones (often needs Administrator) ---
%PS% "try{ Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop | ForEach-Object { [pscustomobject]@{Zone=$_.InstanceName;Temp_C=[math]::Round(($_.CurrentTemperature/10)-273.15,1)} } | Format-Table -AutoSize | Out-String }catch{ 'ACPI thermal zones not exposed by this PC (or run as Administrator).' }"
echo --- Fans reported by Windows ---
%PS% "$f=Get-CimInstance Win32_Fan -ErrorAction SilentlyContinue; if($f){$f | Select-Object Name,Status,ActiveCooling | Format-Table -AutoSize | Out-String}else{'No fan data exposed by Windows.'}"
echo --- LibreHardwareMonitor / OpenHardwareMonitor (if running) ---
%PS% "$found=$false; foreach($ns in 'root\LibreHardwareMonitor','root\OpenHardwareMonitor'){ try{ $s=Get-CimInstance -Namespace $ns -ClassName Sensor -ErrorAction Stop | Where-Object {$_.SensorType -in 'Temperature','Fan','Load','Power'}; if($s){$found=$true; $s | Sort-Object SensorType,Name | Select-Object SensorType,Name,Value | Format-Table -AutoSize | Out-String -Width 200} }catch{} }; if(-not $found){'Not running. Start LibreHardwareMonitor to read CPU/GPU temps and fan RPM here.'}"
where nvidia-smi >nul 2>nul
if errorlevel 1 goto SENS_NONV
echo --- NVIDIA GPU ---
nvidia-smi --query-gpu=name,temperature.gpu,fan.speed,power.draw --format=csv
:SENS_NONV
echo.
echo Tip: BIOS/UEFI Hardware Monitor or the manufacturer utility is most accurate.
exit /b

:S_BATTERY
call :HDR "BATTERY"
%PS% "$b=Get-CimInstance Win32_Battery; if(-not $b){'No battery detected (desktop PC or battery not exposed).'; exit}; $st=@{1='Discharging';2='On AC power';3='Fully charged';4='Low';5='Critical';6='Charging';7='Charging and high';8='Charging and low';9='Charging and critical';10='Undefined';11='Partially charged'}; $b | ForEach-Object { [pscustomobject]@{Name=$_.Name;Chemistry=$_.Chemistry;Charge_Percent=$_.EstimatedChargeRemaining;Status=$st[[int]$_.BatteryStatus];EstimatedRunTime_Min=$_.EstimatedRunTime} | Format-List | Out-String }; try{ $d=(Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction Stop | Select-Object -First 1).DesignedCapacity; $f=(Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction Stop | Select-Object -First 1).FullChargedCapacity; 'Design capacity     : '+$d+' mWh'; 'Full charge capacity: '+$f+' mWh'; 'Battery health      : '+[math]::Round(100*$f/$d,1)+' percent' }catch{ 'Capacity data unavailable (try Administrator or generate battery report).' }"
exit /b

:S_NET
call :HDR "NETWORK"
%PS% "Get-NetAdapter | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress | Format-Table -AutoSize | Out-String -Width 200; Get-NetIPConfiguration | ForEach-Object { [pscustomobject]@{Interface=$_.InterfaceAlias;IPv4=($_.IPv4Address.IPAddress -join ', ');Gateway=$_.IPv4DefaultGateway.NextHop;DNS=($_.DNSServer.ServerAddresses -join ', ')} } | Format-Table -AutoSize | Out-String -Width 200; 'Internet test (8.8.8.8): '+$(if(Test-Connection 8.8.8.8 -Count 2 -Quiet){'ONLINE'}else{'NO RESPONSE'})"
echo --- Wi-Fi details (if connected) ---
netsh wlan show interfaces 2>nul | findstr /i "Name SSID BSSID Radio Signal Receive Transmit Channel"
exit /b

:S_DISPLAY
call :HDR "DISPLAY / MONITORS"
%PS% "try{ Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction Stop | ForEach-Object { $n=($_.UserFriendlyName | Where-Object {$_ -ne 0} | ForEach-Object {[char]$_}) -join ''; $m=($_.ManufacturerName | Where-Object {$_ -ne 0} | ForEach-Object {[char]$_}) -join ''; $s=($_.SerialNumberID | Where-Object {$_ -ne 0} | ForEach-Object {[char]$_}) -join ''; [pscustomobject]@{Monitor=$n;Maker=$m;Serial=$s;Year=$_.YearOfManufacture;Week=$_.WeekOfManufacture} } | Format-List | Out-String }catch{ 'Monitor EDID data unavailable.' }; Get-CimInstance Win32_VideoController | Select-Object Name,CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate,CurrentBitsPerPixel | Format-Table -AutoSize | Out-String -Width 200"
exit /b

:S_PERF
call :HDR "LIVE PERFORMANCE SNAPSHOT"
%PS% "$o=Get-CimInstance Win32_OperatingSystem; $tot=$o.TotalVisibleMemorySize/1MB; $fr=$o.FreePhysicalMemory/1MB; 'CPU load : '+(Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average+' percent'; 'RAM used : '+[math]::Round($tot-$fr,2)+' of '+[math]::Round($tot,2)+' GB'; $dk=Get-CimInstance Win32_PerfFormattedData_PerfDisk_PhysicalDisk | Where-Object {$_.Name -eq '_Total'}; 'Disk busy: '+$dk.PercentDiskTime+' percent  Read '+[math]::Round($dk.DiskReadBytesPersec/1MB,1)+' MB/s  Write '+[math]::Round($dk.DiskWriteBytesPersec/1MB,1)+' MB/s'; ''; 'Top 10 processes by RAM:'; Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Name,Id,@{N='RAM_MB';E={[math]::Round($_.WorkingSet64/1MB,0)}},@{N='CPU_Seconds';E={[math]::Round($_.CPU,1)}} | Format-Table -AutoSize | Out-String"
exit /b

:S_WIN11
call :HDR "WINDOWS 11 COMPATIBILITY CHECK"
%PS% "function r($n,$b,$d){ '{0,-18} {1,-6} {2}' -f $n,$(if($b){'PASS'}else{'FAIL'}),$d }; $c=Get-CimInstance Win32_Processor | Select-Object -First 1; $ram=[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,1); $sz=0; try{$sz=[math]::Round((Get-Volume -DriveLetter ($env:SystemDrive.Substring(0,1))).Size/1GB,0)}catch{}; $uefi=Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'; $tpm=$null; try{$tpm=(Get-CimInstance -Namespace root\cimv2\Security\MicrosoftTpm -ClassName Win32_Tpm -ErrorAction Stop).SpecVersion}catch{}; r 'CPU 64-bit' ($c.AddressWidth -eq 64) ($c.Name.Trim()); r 'CPU 2+ cores' ($c.NumberOfCores -ge 2) ([string]$c.NumberOfCores+' cores'); r 'CPU 1 GHz+' ($c.MaxClockSpeed -ge 1000) ([string]$c.MaxClockSpeed+' MHz'); r 'RAM 4 GB+' ($ram -ge 4) ([string]$ram+' GB'); r 'Storage 64 GB+' ($sz -ge 64) ([string]$sz+' GB system drive'); r 'UEFI firmware' $uefi $(if($uefi){'UEFI'}else{'Legacy BIOS'}); r 'TPM 2.0' ($tpm -like '2.0*') $(if($tpm){$tpm}else{'Not detected / needs Administrator'}); ''; 'Note: CPU model must also be on Microsoft supported list. Use PC Health Check for final verdict.'"
exit /b

:S_STARTUP
call :HDR "STARTUP PROGRAMS"
%PS% "Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location,User | Format-Table -AutoSize -Wrap | Out-String -Width 200"
exit /b

:S_PROBLEMS
call :HDR "PROBLEM DEVICES / DRIVER ERRORS"
%PS% "$p=Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object {$_.Status -ne 'OK'}; if($p){$p | Select-Object Class,FriendlyName,Status,InstanceId | Format-Table -AutoSize -Wrap | Out-String -Width 200}else{'No problem devices found. All present devices report OK.'}"
exit /b

:S_EVENTS
call :HDR "RECENT CRITICAL / ERROR EVENTS (3 DAYS)"
%PS% "try{ $e=Get-WinEvent -FilterHashtable @{LogName='System','Application';Level=1,2;StartTime=(Get-Date).AddDays(-3)} -MaxEvents 20 -ErrorAction Stop; $e | Select-Object TimeCreated,LogName,ProviderName,Id,@{N='Message';E={($_.Message -split [char]10)[0]}} | Format-Table -AutoSize -Wrap | Out-String -Width 200 }catch{ 'No critical or error events found in the last 3 days.' }"
exit /b

:S_SOFTWARE
call :HDR "INSTALLED SOFTWARE"
%PS% "Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName} | Sort-Object DisplayName -Unique | Select-Object DisplayName,DisplayVersion,Publisher | Format-Table -AutoSize | Out-String -Width 200"
exit /b



