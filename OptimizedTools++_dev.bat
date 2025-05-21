@echo off
title OptimizedTools++: Preparing...
REM Run as Admin
setlocal EnableDelayedExpansion
REM Delete the registry key
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v DummyEntry /f >reg_log.txt 2>&1
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v DummyEntry /t REG_SZ /d 1 >reg_log.txt 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

cls
echo.
echo    ------------ YOU ARE RUNNING AN UNSTABLE BUILD ------------
echo    This build is not recommended for production use.
echo    It is intended for testing and development purposes only.
echo    Please use at your own risk.
echo
echo    Detected: You are running this unstable build directly from the source code.
echo    This version may contain experimental features, incomplete tweaks, or bugs.
echo    For the latest stable release, visit: https://github.com/NammIsADev/OptimizedToolsPlusPlus/releases
echo.
echo    ------------------------------------------------------------
echo.
setlocal EnableDelayedExpansion
echo    OptimizedTools++ only supports Windows 10 or newer.
echo    Please run it on a compatible version.
echo    If you are running Windows 8 or older, please upgrade your OS.
echo.
echo    Warning: Running this program on an outdated version of Windows may result in system corruption.
echo    Proceed with caution!
echo.
pause

echo.
echo Detecting Windows version...

for /f "tokens=*" %%a in ('systeminfo ^| findstr /B /C:"OS Name"') do (
    set "OS_Name=%%a"
)

echo Detected OS: %OS_Name%

echo.

REM Check if "Windows 10" is in OS_Name
echo "%OS_Name%" | findstr /i "Windows 10" >nul
if %errorlevel% equ 0 (
    echo Windows 10 detected. Proceeding with the script...
    goto :continue
)

REM Check if "Windows 11" is in OS_Name
echo "%OS_Name%" | findstr /i "Windows 11" >nul
if %errorlevel% equ 0 (
    echo Windows 11 detected. Proceeding with the script...
    goto :continue
)

REM If neither is found
echo This version of Windows is not supported. Exiting...
pause
exit /b 1

:continue
Mode 100,43

REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")
REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM Save the current directory
set CURRENT_DIR=%~dp0

REM Change to the 'bin' directory within the current directory
cd /d %CURRENT_DIR%bin

:update
echo.
echo                   --------------------------------------------------------------
echo                                        Check for updates
echo                   --------------------------------------------------------------
echo.
echo                                    Checking for new updates...
echo                                           Please wait.
echo.

:: Download the latest version info
curl -s -o "%temp%\check.txt" https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/update/check.txt
ping -n 5 localhost > nul

:: Read the file content
set /p fileContent=<%temp%\check.txt

:: Check the content and decide the action
if "!fileContent!"=="1.0.0" (
    echo                         Your version is !fileContent!, you are up to date.
    ping -n 3 localhost > nul
) else (
    echo                           We found a new version. Newer version: !fileContent!
    echo                                        Do you want to update?
    :loop2
    Batbox /h 0
    Call Button 35 14 "Yes" 55 14 "No" # Press
    Getinput /m %Press% /h 70
    :: Check for the pressed button 
    if %errorlevel%==1 (goto openGitHub)
    if %errorlevel%==2 (goto restorepoint)
    goto loop2
    ping -n 5 localhost > nul

    :openGitHub
    cls
    echo.
    echo                                        Opening GitHub page...
    start "" "https://github.com/NammIsADev/OptimizedToolsPlusPlus/releases/latest"
    exit
)



:restorepoint
cls
echo.
echo                   --------------------------------------------------------------
echo                                          Restore Point
echo                   --------------------------------------------------------------
echo.
echo                                     Create a restore point?
echo.
echo.
echo.
goto loop

:loop
Batbox /h 0

Call Button 35 10 "Yes" 55 10 "No" # Press
Getinput /m %Press% /h 70

:: Check for the pressed button 
if %errorlevel%==1 (goto startbackup)
if %errorlevel%==2 (goto dir)
goto loop

:startbackup
cd..
mkdir OPTPlusPlus >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'OptimizedTools++ Restore Point' >nul 2>&1
REM HKCU & HKLM backups
mkdir OPTPlusPlusTemp\RegRevert >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.% 
>nul 2>&1 md OPTPlusPlusTemp\RegRevert\%date1%
reg export HKCU OPTPlusPlusTemp\RegRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU OPTPlusPlusTemp\RegRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > OPTPlusPlusTemp\RegRevert\firstlaunchcheck

:dir
cd..
REM Make Directories
mkdir OPTPlusPlus >nul 2>&1
mkdir OPTPlusPlus\Resources >nul 2>&1
mkdir OPTPlusPlus\Drivers >nul 2>&1
mkdir OPTPlusPlus\Renders >nul 2>&1
cd OPTPlusPlus
REM Show Detailed BSoD
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1
goto warn

:warn
cls
title OptimizedTools++: Warning
echo.
echo.
call :title
echo.
echo                          %COL%[36mRework version of old OptimizedTools version.%COL%[0m
echo                                   Simple - fast - lightweight.
echo                         NOTE: OptimizedTools++ is free and open-source. 
echo              If you paid for this program/downloaded from another source (not GitHub)
echo                       %COL%[33mPLEASE DELETE THE PROGRAM, SCAN YOUR PC FOR VIRUS NOW!!%COL%[0m
echo.
echo.
echo    %COL%[91mWARNING:%COL%[0m
echo    %COL%[91mUse at your own risk.%COL%[0m
echo    I am not %COL%[91mRESPONSIBLE%COL%[0m for cases of BSOD after tweaking, 
echo    unable to boot after restart, missing files/OS not working properly, etc.
echo.
echo    %COL%[91mPLEASE%COL%[0m do some research if you have any questions about the features 
echo    included in this software before you use it.
echo.
echo    %COL%[91mYOU%COL%[0m are choosing to make these modifications, and if you %COL%[91mPOINT%COL%[0m the finger 
echo    at me for damaging your operating system, I will laugh at you.
echo.
echo    Even though my software have an automatic restore point feature, I highly recommend 
echo    making a manual restore point before running.
echo.
echo    For any questions and/or concerns, please go to my GitHub: NammIsADev/OptimizedToolsPlusPlus
echo    Type "Yes" to continue: 
set /p "input=%DEL%                                     Your input:
if /i "!input!" neq "yes" goto warn
reg add "HKCU\Software\opt" /v "Disclaimer" /f >nul 2>&1
goto tweaksMenu1

:tweaksMenu1
title OptimizedTools++
cls
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
call :title
echo.
echo                   --------------------------------------------------------------
echo                                         Windows Tweaks Menu
echo                   --------------------------------------------------------------
echo.
echo     1. Disable Startup Delay
echo     2. Enable Dark Mode
echo     3. Disable Telemetry
echo     4. Optimize Network Performance
echo     5. Disable Cortana
echo     6. Enable File Extensions
echo     7. Disable Animations
echo     8. Clear Temporary Files
echo     9. Enable Faster Shutdown
echo     10. Remove Bloatware
echo     11. Debloat Windows 10/11
echo     12. Disable Windows Defender
echo     13. Enable Classic Taskbar (may not work on 23H2+)
echo     14. Disable Action Center
echo     15. Enable Verbose Boot
echo     16. Uninstall OneDrive
echo     17. Disable Background Apps
echo     18. Disable Fullscreen Optimizations
echo     19. Next Page
echo.
echo                                           Welcome. %username%
set /p "choice=%DEL%                                  Your choice: "

if "%choice%"=="1" goto disableStartupDelay
if "%choice%"=="2" goto enableDarkMode
if "%choice%"=="3" goto disableTelemetry
if "%choice%"=="4" goto optimizeNetwork
if "%choice%"=="5" goto disableCortana
if "%choice%"=="6" goto enableFileExtensions
if "%choice%"=="7" goto disableAnimations
if "%choice%"=="8" goto clearTempFiles
if "%choice%"=="9" goto fasterShutdown
if "%choice%"=="10" goto removeBloatware
if "%choice%"=="11" goto debloatWindows
if "%choice%"=="12" goto disableWindowsDefender
if "%choice%"=="13" goto enableClassicTaskbar
if "%choice%"=="14" goto disableActionCenter
if "%choice%"=="15" goto enableVerboseBoot
if "%choice%"=="16" goto uninstallOneDrive
if "%choice%"=="17" goto disableBackgroundApps
if "%choice%"=="18" goto disableFullscreenOptimizations
if "%choice%"=="19" goto tweaksMenuPage2
goto tweaksMenu1

:disableStartupDelay
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f
echo Disabled Startup Delay.
pause
goto tweaksMenu1

:enableDarkMode
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f
echo Enabled Dark Mode.
pause
goto tweaksMenu1

:disableTelemetry
cls
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
echo 127.0.0.1 vortex.data.microsoft.com >> %windir%\System32\drivers\etc\hosts
echo 127.0.0.1 telemetry.microsoft.com >> %windir%\System32\drivers\etc\hosts
echo 127.0.0.1 watson.telemetry.microsoft.com >> %windir%\System32\drivers\etc\hosts
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v RoamingProfileSupportEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SyncSettings" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v PeriodInDays /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f

:: Delete NVIDIA shader cache files
echo Deleting NVIDIA shader cache...
del /q "%temp%\NVIDIA Corporation\NV_Cache\*"
del /q "%programdata%\NVIDIA Corporation\NV_Cache\*"

:: Stop and disable Visual Studio Standard Collector Service
echo Stopping and disabling VSStandardCollectorService150...
sc stop VSStandardCollectorService150
sc config VSStandardCollectorService150 start= disabled

:: Terminate CCleaner processes
echo Terminating CCleaner processes...
taskkill /f /im ccleaner.exe
taskkill /f /im ccleaner64.exe

:: Disable telemetry-related registry keys
echo Disabling telemetry-related registry keys...
reg add "HKCU\Software\Piriform\CCleaner" /v "(Cfg)SoftwareUpdaterIpm" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "(Cfg)SoftwareUpdater" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "(Cfg)QuickCleanIpm" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "(Cfg)QuickClean" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "(Cfg)HealthCheck" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "CheckTrialOffer" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "UpdateCheck" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "UpdateAuto" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "SystemMonitoring" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "HelpImproveCCleaner" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "Monitoring" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Piriform\CCleaner" /v "HomeScreen" /t REG_SZ /d "2" /f

:: Disable telemetry in Google Chrome
echo Disabling telemetry in Google Chrome...
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupReportingEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ChromeCleanupEnabled" /t REG_DWORD /d 0 /f

:: Disable telemetry in Microsoft Visual Studio
echo Disabling telemetry in Microsoft Visual Studio...
reg add "HKLM\Software\Policies\Microsoft\VisualStudio\Feedback" /v "DisableScreenshotCapture" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\VisualStudio\Feedback" /v "DisableEmailInput" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\VisualStudio\Feedback" /v "DisableFeedbackDialog" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\VisualStudio\Telemetry" /v "TurnOffSwitch" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\VSCommon\17.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\VSCommon\16.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\VSCommon\15.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\VSCommon\14.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\VSCommon\17.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\VSCommon\16.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\VSCommon\15.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\VSCommon\14.0\SQM" /v "OptIn" /t REG_DWORD /d 0 /f

:: Disable telemetry in Microsoft Office
echo Disabling telemetry in Microsoft Office...
reg add "HKCU\SOFTWARE\Microsoft\Office\17.0\Common" /v "QMEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Office\16.0\Common" /v "QMEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Office\15.0\Common" /v "QMEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Office\16.0\Common\Feedback" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Office\15.0\Common\Feedback" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\17.0\OSM" /v "EnableUpload" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\16.0\OSM" /v "EnableUpload" /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Office\15.0\OSM" /v 
echo Disabled Telemetry.
pause
goto tweaksMenu1

:optimizeNetwork
cls
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f
echo Optimized Network Performance.
pause
goto tweaksMenu1

:disableCortana
cls
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
echo Disabled Cortana.
pause
goto tweaksMenu1

:enableFileExtensions
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
echo Enabled File Extensions.
pause
goto tweaksMenu1

:disableAnimations
cls
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f
echo Disabled Animations.
pause
goto tweaksMenu1

:clearTempFiles
cls
del /q /s %temp%\*
echo Cleared Temporary Files.
pause
goto tweaksMenu1

:fasterShutdown
cls
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d 2000 /f
echo Enabled Faster Shutdown.
pause
goto tweaksMenu1

:removeBloatware
cls
echo Removing ALL pre-installed Windows apps including Store, Photos, Camera, Terminal...
echo This may break app installations or basic tools. Proceeding anyway.

REM Remove installed AppxPackages for all users
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Get-AppxPackage -AllUsers ^
| ForEach-Object {
    try {
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction Stop
        Write-Output ('Removed: ' + $_.Name)
    } catch {
        Write-Output ('Failed to remove: ' + $_.Name)
    }
}"

REM Remove provisioned AppxPackages (preinstalled for new users)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"Get-AppxProvisionedPackage -Online ^
| ForEach-Object {
    try {
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction Stop
        Write-Output ('Removed provisioned: ' + $_.DisplayName)
    } catch {
        Write-Output ('Failed to remove provisioned: ' + $_.DisplayName)
    }
}"

echo.
echo All pre-installed apps (including Store, Photos, Terminal, etc.) removed.
pause
goto tweaksMenu1

:debloatWindows
cls
echo Debloating Windows...
:: Disable Xbox services
sc config XblAuthManager start= disabled >nul 2>&1
sc config XblGameSave start= disabled >nul 2>&1
sc config XboxNetApiSvc start= disabled >nul 2>&1

:: Disable telemetry services
sc config DiagTrack start= disabled >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1

:: Disable Cortana
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable OneDrive
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSync" /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable unnecessary startup apps
powershell -Command "Get-CimInstance Win32_StartupCommand | Where-Object { $_.Command -like '*OneDrive*' -or $_.Command -like '*Teams*' } | Remove-CimInstance"

echo Windows debloated successfully.
pause
goto tweaksMenu1

:disableWindowsDefender
cls
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f
echo Disabled Windows Defender.
pause
goto tweaksMenu1

:enableClassicTaskbar
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d 1 /f
echo Enabled Classic Taskbar.
pause
goto tweaksMenu1

:disableActionCenter
cls
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f
echo Disabled Action Center.
pause
goto tweaksMenu1

:enableVerboseBoot
cls
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f
echo Enabled Verbose Boot.
pause
goto tweaksMenu1

:uninstallOneDrive
cls
echo Uninstalling OneDrive...
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Microsoft\OneDrive" /f >nul 2>&1
echo OneDrive uninstalled successfully.
pause
goto tweaksMenu1

:disableBackgroundApps
cls
echo Disabling Background Apps...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo Background Apps disabled successfully.
pause
goto tweaksMenu1

:disableFullscreenOptimizations
cls
echo Disabling Fullscreen Optimizations...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo Fullscreen Optimizations disabled successfully.
pause
goto tweaksMenu1

:tweaksMenuPage2
cls
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
call :title
echo.
echo                   --------------------------------------------------------------
echo                                    Windows Tweaks Menu (Page 2)
echo                   --------------------------------------------------------------
echo.
echo     20. Disable Microsoft Copilot
echo     21. Disable IPv6
echo     22. Disable Teredo
echo     23. Set Classic Right-Click Menu
echo     24. Uninstall Microsoft Edge (Powered by ShadowWhisperer)
echo     25. Install Useful Apps (Notepad++, Discord, Browser, supported at dev ver)
echo     26. Enable Ultimate Performance Plan
echo     27. Turn Off Reserved Storage
echo     28. Tweak TCP/IP Settings
echo     29. Flush DNS Cache
echo     30. Enable Large System Cache
echo     31. Optimize GPU Scheduling (Intel/AMD)
echo     32. Turn Off Spectre and Meltdown Mitigations (CAUTION)
echo     33. (NVIDIA) GPU Optimization
echo     34. Auto Tweaks for Desktop/Laptop
echo     35. Activate Windows (Powered by MAS)
echo     36. Disable HPET
echo     37. Enhance System and Network Performance
echo     38. Disable Unnecessary Windows Services
echo     39. Disable Office Telemetry
echo     40. Change DNS Server
echo     41. Back to Main Menu
echo     42. Go to Page 3
echo.
echo                                           Welcome. %username%
set /p "choice=%DEL%                                  Your choice: "

if "%choice%"=="20" goto disableMicrosoftCopilot
if "%choice%"=="21" goto disableIPv6
if "%choice%"=="22" goto disableTeredo
if "%choice%"=="23" goto setClassicRightClickMenu
if "%choice%"=="24" goto removeEdge
if "%choice%"=="25" goto installUsefulApps
if "%choice%"=="26" goto enableUltimatePerformance
if "%choice%"=="27" goto turnOffReservedStorage
if "%choice%"=="28" goto tweakTCPIP
if "%choice%"=="29" goto flushDNSCache
if "%choice%"=="30" goto enableLargeSystemCache
if "%choice%"=="31" goto optimizeGPUScheduling
if "%choice%"=="32" goto turnOffSpectreMeltdown
if "%choice%"=="41" goto tweaksMenu1
if "%choice%"=="33" goto nvidiaOptimization
if "%choice%"=="34" goto autoTweaks
if "%choice%"=="35" goto activateWindows
if "%choice%"=="36" goto disableHPET
if "%choice%"=="37" goto enhanceSystemNetwork
if "%choice%"=="38" goto disableUnnecessaryServices
if "%choice%"=="39" goto disableOfficeTelemetry
if "%choice%"=="40" goto changeDNS
if "%choice%"=="42" goto tweaksMenuPage3
goto tweaksMenuPage2

:disableMicrosoftCopilot
cls
echo Disabling Microsoft Copilot...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Copilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
echo Microsoft Copilot disabled. You might need to restart Explorer or your computer for the change to take full effect.
pause
goto tweaksMenuPage2

:disableIPv6
cls
echo Disabling IPv6...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
echo IPv6 disabled. You might need to restart your computer for the changes to take effect.
pause
goto tweaksMenuPage2

:disableTeredo
cls
echo Disabling Teredo...
netsh interface teredo set state disabled
echo Teredo disabled.
pause
goto tweaksMenuPage2

:setClassicRightClickMenu
cls
echo Setting classic right-click menu...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f >nul 2>&1
echo Classic right-click menu set. You might need to restart Explorer for the change to take effect.
pause
goto tweaksMenuPage2

:removeEdge
cls
echo Uninstalling Microsoft Edge...
echo This process uses PowerShell and might take a few moments.
echo Method 1: trying
powershell -Command "Get-AppxPackage -Name Microsoft.MicrosoftEdge.* | Remove-AppxPackage"
echo Microsoft Edge uninstallation initiated. Check the PowerShell window for progress.
echo Method 2: trying
net session >NUL 2>&1 || (echo. & echo Run Script As Admin & echo. & pause & exit)
title Edge Remover - 2/18/2025 - Powered by ShadowWhisperer
set "expected=4963532e63884a66ecee0386475ee423ae7f7af8a6c6d160cf1237d085adf05e"

set "onHashErr=download"

set "fileSetup=%~dp0setup.exe"
if exist "%fileSetup%" goto file_check;
set "fileSetup=%tmp%\setup.exe"
if exist "%fileSetup%" goto file_check;

:file_download
set "onHashErr=error"
ipconfig | find "IPv" >NUL
if %errorlevel% neq 0 echo. & echo You are not connected to a network ! & echo. & pause & exit

echo - Downloading Required File
powershell -Command "try { (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ShadowWhisperer/Remove-MS-Edge/main/_Source/setup.exe', '%fileSetup%') } catch { Write-Host 'Error downloading the file.' }"
if not exist "%fileSetup%" echo File download failed. Check your internet connection & echo & pause & exit

:file_check
powershell -Command "exit ((Get-FileHash '%fileSetup%' -Algorithm SHA256).Hash.ToLower() -ne '%expected%')"
if %errorlevel% neq 0 goto file_%onHashErr%
echo. & goto uninst_edge

:file_error
echo File hash does not match the expected value. & echo & pause & exit


REM #Edge
:uninst_edge
echo - Removing Edge
where /q "%ProgramFiles(x86)%\Microsoft\Edge\Application:*"
if %errorlevel% neq 0 goto uninst_wv
start /w "" "%fileSetup%" --uninstall --system-level --force-uninstall

REM #WebView
:uninst_wv
echo - Removing WebView
where /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView\Application:*"
if %errorlevel% neq 0 goto cleanup_wv_junk
start /w "" "%fileSetup%" --uninstall --msedgewebview --system-level --force-uninstall
REM Delete empty folders
:cleanup_wv_junk
REM rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView" >NUL 2>&1
for /f "delims=" %%d in ('dir /ad /b /s "%ProgramFiles(x86)%\Microsoft\EdgeWebView" 2^>NUL ^| sort /r') do rd "%%d" 2>NUL


REM Desktop icon
:users_cleanup
echo - Removing Additional Files

set "REG_USERS_PATH=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%" /v Public') do ( call :user_rem_lnks_by_path %%d )
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%" /v Default') do ( call :user_rem_lnks_by_path %%d )
for /f "skip=1 tokens=7 delims=\" %%k in ('reg query "%REG_USERS_PATH%" /k /f "*"') do ( call :user_rem_lnks_by_sid %%k )
goto users_done

:user_rem_lnks_by_sid
if "%1"=="S-1-5-18" goto user_end
if "%1"=="S-1-5-19" goto user_end
if "%1"=="S-1-5-20" goto user_end
for /f "skip=2 tokens=2*" %%c in ('reg query "%REG_USERS_PATH%\%1" /v ProfileImagePath') do (
	call :user_rem_lnks_by_path %%d
	if "%UserProfile%"=="%%d" set "USER_SID=%1"
)
goto user_end

:user_rem_lnks_by_path
del /s /q "%1\Desktop\edge.lnk" >NUL 2>&1
del /s /q "%1\Desktop\Microsoft Edge.lnk" >NUL 2>&1

:user_end
exit /b 0

:users_done

REM System32
if exist "%SystemRoot%\System32\MicrosoftEdgeCP.exe" (
for /f "delims=" %%a in ('dir /b "%SystemRoot%\System32\MicrosoftEdge*"') do (
 takeown /f "%SystemRoot%\System32\%%a" >NUL 2>&1
 icacls "%SystemRoot%\System32\%%a" /inheritance:e /grant "%UserName%:(OI)(CI)F" /T /C >NUL 2>&1
 del /S /Q "%SystemRoot%\System32\%%a" >NUL 2>&1))

REM Folders
taskkill /im MicrosoftEdgeUpdate.exe /f >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\Edge" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeCore" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" >NUL 2>&1
rd /s /q "%ProgramFiles(x86)%\Microsoft\Temp" >NUL 2>&1
rd /s /q "%AllUsersProfile%\Microsoft\EdgeUpdate" >NUL 2>&1

REM Files
del /s /q "%AllUsersProfile%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" >NUL 2>&1

REM Registry
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f >NUL 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Edge" /f >NUL 2>&1

REM Tasks - Files
for /r "%SystemRoot%\System32\Tasks" %%f in (*MicrosoftEdge*) do del "%%f" >NUL 2>&1

REM Tasks - Name
for /f "skip=1 tokens=1 delims=," %%a in ('schtasks /query /fo csv') do (
for %%b in (%%a) do (
 if "%%b"=="MicrosoftEdge" schtasks /delete /tn "%%~a" /f >NUL 2>&1))

REM Update Services
set "service_names=edgeupdate edgeupdatem"
for %%n in (%service_names%) do (
 sc stop %%n >NUL 2>&1
 sc delete %%n >NUL 2>&1
 reg delete "HKLM\SYSTEM\CurrentControlSet\Services\%%n" /f >NUL 2>&1
)


REM #APPX
echo - Removing APPX

if defined USER_SID goto rem_appX
for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"

:rem_appX
set "REG_APPX_STORE=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like '*microsoftedge*' } | Select-Object -ExpandProperty PackageFullName"') do (
    if not "%%a"=="" (
        reg add "%REG_APPX_STORE%\EndOfLife\%USER_SID%\%%a" /f >NUL 2>&1
        reg add "%REG_APPX_STORE%\EndOfLife\S-1-5-18\%%a" /f >NUL 2>&1
        reg add "%REG_APPX_STORE%\Deprovisioned\%%a" /f >NUL 2>&1
        powershell -Command "Remove-AppxPackage -Package '%%a'" 2>NUL
        powershell -Command "Remove-AppxPackage -Package '%%a' -AllUsers" 2>NUL
    )
)

REM %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*
for /d %%d in ("%SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*") do (
 takeown /f "%%d" /r /d y >NUL 2>&1
 icacls "%%d" /grant administrators:F /t >NUL 2>&1
 rd /s /q "%%d" >NUL 2>&1)
pause
title OptimizedTools++
goto tweaksMenuPage2

:installUsefulApps
cls
echo Installing useful applications...

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo Chocolatey not found. Installing Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "Set-ExecutionPolicy Bypass -Scope Process -Force; ^
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ^
      iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorlevel% neq 0 (
        echo Failed to install Chocolatey. Please install it manually and re-run this script.
        pause
        goto tweaksMenuPage2
    )
    echo Chocolatey installed successfully.
) else (
    echo Chocolatey is already installed.
)

REM Install useful applications
echo Installing Notepad++, Discord, Firefox, VLC, and WinRAR...
choco install -y notepadplusplus discord firefox vlc winrar

echo.
echo All applications installed successfully.
pause
goto tweaksMenuPage2


:enableUltimatePerformance
cls
echo Enabling Ultimate Performance power plan...

echo Checking for Ultimate Performance power scheme...
powercfg /list | findstr /i "Ultimate Performance" >nul 2>&1

if %errorlevel% neq 0 (
    echo Ultimate Performance scheme not found. Attempting to create it...
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    if %errorlevel% equ 0 (
        echo Ultimate Performance scheme created successfully.
    ) else (
        echo Failed to create Ultimate Performance scheme.
        echo This feature may not be supported on your system.
        pause
        goto tweaksMenuPage2
    )
) else (
    echo Ultimate Performance scheme already exists.
)

echo.
echo Applying power scheme changes...

:: Step 1: Activate Balanced (optional reset)
powercfg -setactive scheme_min
if %errorlevel% neq 0 echo [Warning] Failed to activate 'Balanced' (scheme_min)

:: Step 2: Activate Ultimate Performance
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
if %errorlevel% neq 0 echo [Warning] Failed to activate 'Ultimate Performance'

:: Step 3: Activate custom plan (replace GUID if needed)
powercfg /S ceb6bfc7-d55c-4d56-ae37-ff264aade12d
if %errorlevel% neq 0 echo [Warning] Failed to activate custom power plan

:: Step 4: Set AC standby timeout to 0 (never)
powercfg /X standby-timeout-ac 0
if %errorlevel% neq 0 echo [Warning] Failed to set AC standby timeout

:: Step 5: Set DC standby timeout to 0 (never)
powercfg /X standby-timeout-dc 0
if %errorlevel% neq 0 echo [Warning] Failed to set DC standby timeout

echo.
echo All power settings applied.
pause
goto tweaksMenuPage2


:: Set the Ultimate Performance scheme as active
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
if %errorlevel% equ 0 (
    echo Ultimate Performance power plan enabled.
) else (
    echo Failed to enable Ultimate Performance power plan.
    echo This feature might not be supported on your system.
)

pause
goto tweaksMenuPage2

:turnOffReservedStorage
cls
echo Turning off reserved storage...
reg add "HKLM\Software\Microsoft\Windows\ReservedStorage" /v "AllowUninstall" /t REG_DWORD /d 1 /f >nul 2>&1
echo Attempting to turn off reserved storage. This might not be effective on all systems and might require further steps or a reboot.
pause
goto tweaksMenuPage2

:tweakTCPIP
cls
echo Tweaking TCP/IP settings...

REM Enable TCP Fast Open (Windows 10+ supports this partially)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpFastOpen" /t REG_DWORD /d 1 /f

REM Optimize TCP Window Size — note: TcpWindowSize is legacy and usually ignored in modern Windows
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpWindowSize" /t REG_DWORD /d 65535 /f

REM Disable Nagle’s Algorithm and enable low-latency ACK — REPLACE {YourInterfaceGUID} with actual network adapter GUID
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YourInterfaceGUID}" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{YourInterfaceGUID}" /v "TCPNoDelay" /t REG_DWORD /d 1 /f

REM Enable ECN (Explicit Congestion Notification)
netsh int tcp set global ecncapability=enabled

REM Enable RSS (Receive Side Scaling)
netsh int tcp set global rss=enabled

REM Enable Chimney Offload — note: deprecated in latest Windows versions
netsh int tcp set global chimney=enabled

echo TCP/IP tweaks applied successfully.
pause
goto tweaksMenuPage2

:flushDNSCache
cls
echo Flushing DNS cache...
ipconfig /flushdns
echo DNS cache flushed successfully.
pause
goto tweaksMenuPage2

:enableLargeSystemCache
cls
echo Enabling large system cache...
echo Warning: Enabling large system cache can improve performance for certain workloads but may affect system stability.
set /p "enableLargeCache=Enable large system cache now? (y/n): "
if /i "%enableLargeCache%"=="y" (
    reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
    echo Large system cache enabled.
) else (
    echo Skipping large system cache.
)
pause
goto tweaksMenuPage2

:optimizeGPUScheduling
cls
echo Optimizing GPU scheduling...
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
echo Hardware-accelerated GPU scheduling enabled. You might need to restart your computer.
pause
goto tweaksMenuPage2

:turnOffSpectreMeltdown
cls
echo Turning off Spectre and Meltdown mitigations...
echo Warning: Disabling these mitigations can improve performance but might increase security risks. Proceed with caution.
set /p "disableMitigations=Are you sure you want to disable Spectre & Meltdown mitigations? (y/n): "
if /i "%disableMitigations%"=="y" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\FeatureSettingsOverride" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\FeatureSettingsOverride" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1
    echo Spectre and Meltdown mitigations disabled. A system restart is highly recommended.
) else (
    echo Spectre and Meltdown mitigations not disabled.
)
pause
goto tweaksMenuPage2

:nvidiaOptimization
cls
echo Optimizing NVIDIA GPU settings...
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerLevel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerLevelAC" /t REG_DWORD /d 0 /f >nul 2>&1
echo NVIDIA GPU settings optimized successfully.
pause
goto tweaksMenuPage2

:autoTweaks
cls
echo Applying auto tweaks for Desktop/Laptop...
for /f "tokens=2 delims==" %%i in ('wmic computersystem get pcSystemType /value') do set "pcType=%%i"
if "%pcType%"=="2" (
    echo Detected Desktop. Applying desktop-specific tweaks...
    reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoLowDiskSpaceChecks" /t REG_DWORD /d 1 /f >nul 2>&1
) else (
    echo Detected Laptop. Applying laptop-specific tweaks...
    powercfg /setactive SCHEME_BALANCED
    reg add "HKLM\System\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
)
echo Auto tweaks applied successfully.
pause
goto tweaksMenuPage2

:activateWindows
cls
echo Activating Windows...
echo Downloading HWID activation script...
curl -o "temp_hwid.cmd" "https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/master/MAS/Separate-Files-Version/Activators/HWID_Activation.cmd"
if "%errorlevel%"=="0" (
    echo HWID activation script downloaded successfully.
    echo.
    echo Running HWID activation script...
    call "temp_hwid.cmd"
    pause
    if "%errorlevel%"=="0" (
        echo.
        echo HWID activation process completed.
    ) else (
        echo.
        echo Error occurred during HWID activation. Please check the output of the script.
    )
    echo.
    echo Removing temporary HWID activation script...
    del /f /q "temp_hwid.cmd"
    if "%errorlevel%"=="0" (
        echo Temporary script removed.
    ) else (
        echo Error removing temporary script.
    )
) else (
    echo Error downloading HWID activation script. Please check your internet connection.
)

echo.
pause
goto tweaksMenuPage2

:disableHPET
cls
echo Disabling HPET...
bcdedit /set useplatformclock false
echo HPET disabled successfully.
pause
goto tweaksMenuPage2

:enhanceSystemNetwork
cls
echo Enhancing system and network performance...
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global rss=enabled
reg add "HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d 3 /f
echo System and network performance enhanced successfully.
pause
goto tweaksMenuPage2

:disableUnnecessaryServices
cls
echo Disabling unnecessary Windows services...

sc config "DiagTrack" start= disabled
sc config "dmwappushservice" start= disabled
sc config "WSearch" start= disabled
sc config "SysMain" start= disabled
sc config "XboxGipSvc" start= disabled
sc config "XboxNetApiSvc" start= disabled
sc config "XblGameSave" start= disabled
sc config "XblAuthManager" start= disabled
sc config "RemoteRegistry" start= disabled
sc config "CDPUserSvc" start= disabled
sc config "OneSyncSvc" start= disabled
sc config "Fax" start= disabled
sc config "Spooler" start= disabled
sc config "SharedAccess" start= disabled
sc config "RemoteAccess" start= disabled
sc config "RasMan" start= disabled
sc config "Netlogon" start= disabled
sc config "KtmRm" start= disabled
sc config "MSDTC" start= disabled
sc config "TrkWks" start= disabled
sc config "ShellHWDetection" start= disabled
sc config "Themes" start= disabled
sc config "TabletInputService" start= disabled
sc config "WERSvc" start= disabled

echo Unnecessary services disabled successfully.
pause
goto tweaksMenuPage2

:disableOfficeTelemetry
cls
echo Disabling Office telemetry...
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Telemetry" /v "DisableTelemetry" /t REG_DWORD /d 1 /f
echo Office telemetry disabled successfully.
pause
goto tweaksMenuPage2

:changeDNS
cls
echo Changing DNS server...
echo 1. Google DNS (8.8.8.8, 8.8.4.4)
echo 2. Cloudflare DNS (1.1.1.1, 1.0.0.1)
echo 3. OpenDNS (208.67.222.222, 208.67.220.220)
set /p "dnsChoice=%DEL%                                     Your choice: "
if "%dnsChoice%"=="1" (
    netsh interface ip set dns name="Ethernet" static 8.8.8.8
    netsh interface ip add dns name="Ethernet" 8.8.4.4 index=2
) else if "%dnsChoice%"=="2" (
    netsh interface ip set dns name="Ethernet" static 1.1.1.1
    netsh interface ip add dns name="Ethernet" 1.0.0.1 index=2
) else if "%dnsChoice%"=="3" (
    netsh interface ip set dns name="Ethernet" static 208.67.222.222
    netsh interface ip add dns name="Ethernet" 208.67.220.220 index=2
) else (
    echo Invalid choice. Skipping DNS change.
)
echo DNS server changed successfully.
pause
goto tweaksMenuPage2

:tweaksMenuPage3
cls
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
call :title
echo.
echo                   --------------------------------------------------------------
echo                                    Windows Tweaks Menu (Page 3)
echo                   --------------------------------------------------------------
echo.
echo     43. Disable Windows Updates (Caution: may affect security)
echo     44. Align Taskbar to Left (Windows 11+ only)
echo     45. Disable NTFS Indexing
echo     46. Disable SmartScreen (Caution: may affect security)
echo     47. Disable Superfetch (Caution: may affect performance)
echo     48. Disable Microsoft Store App Updates
echo     49. Hide Widgets and Weather
echo     50. Disable Search in Taskbar
echo     51. Disable Startup Items
echo     52. Reinstall Microsoft Store (beta, may not work)
echo     53. Disable Edge WebWidget
echo     54. Add delay to menu boot (3 seconds, only dual boot)
echo     55. Disable Hibernation and Fast Startup
echo     56. Disable Windows Insinder (Caution: cause bug in Settings app)
echo     57. Disable App Launch Tracking
echo     58. Disable App Suggestions
echo     59. Disable Power Throttling (Intel Gen 6+)
echo     60. Disable Background Apps (for god sake smooth)
echo     61. Back to Main Menu
echo     62. Back to Page 2
echo     63. Go to Page 4
echo.
echo                                           Welcome. %username%
set /p "choice=%DEL%                                 Your choice: "

if "%choice%"=="43" goto disableWindowsUpdates
if "%choice%"=="44" goto alignTaskbarLeft
if "%choice%"=="45" goto disableNTFSIndexing
if "%choice%"=="46" goto disableSmartScreen
if "%choice%"=="47" goto disableSuperfetch
if "%choice%"=="48" goto disableStoreAppUpdates
if "%choice%"=="49" goto hideWidgetsWeather
if "%choice%"=="50" goto disableSearchTaskbar
if "%choice%"=="51" goto askDisableStartup
if "%choice%"=="52" goto reins
if "%choice%"=="53" goto disablewebwidget
if "%choice%"=="54" goto dualboot
if "%choice%"=="55" goto fastanddisable
if "%choice%"=="56" goto insider
if "%choice%"=="57" goto apptrack
if "%choice%"=="58" goto appsuggest
if "%choice%"=="59" goto powerthrottle
if "%choice%"=="60" goto tweaksMenuPage2
if "%choice%"=="61" goto tweaksMenu1
if "%choice%"=="62" goto tweaksMenuPage2
if "%choice%"=="63" goto tweaksMenuPage4
goto tweaksMenuPage3

:disableWindowsUpdates
cls
echo Disabling Windows Updates...
sc config wuauserv start= disabled >nul 2>&1
sc stop wuauserv >nul 2>&1
echo Windows Updates disabled successfully.
pause
goto tweaksMenuPage3

:alignTaskbarLeft
cls
echo Aligning Taskbar to Left...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul 2>&1
echo Taskbar aligned to the left successfully.
pause
goto tweaksMenuPage3

:disableNTFSIndexing
cls
echo Disabling NTFS Indexing...
fsutil behavior set disablelastaccess 1 >nul 2>&1
echo NTFS Indexing disabled successfully.
pause
goto tweaksMenuPage3

:disableSmartScreen
cls
echo Disabling SmartScreen...
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
echo SmartScreen disabled successfully.
pause
goto tweaksMenuPage3

:disableSuperfetch
cls
echo Disabling Superfetch...
sc config SysMain start= disabled >nul 2>&1
sc stop SysMain >nul 2>&1
echo Superfetch disabled successfully.
pause
goto tweaksMenuPage3

:disableStoreAppUpdates
cls
echo Disabling Microsoft Store App Updates...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo Microsoft Store App Updates disabled successfully.
pause
goto tweaksMenuPage3

:hideWidgetsWeather
cls
echo Hiding Widgets and Weather...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
echo Widgets and Weather hidden successfully.
pause
goto tweaksMenuPage3

:disableSearchTaskbar
cls
echo Disabling Search in Taskbar...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul 2>&1
echo Search in Taskbar disabled successfully.
pause
goto tweaksMenuPage3

:askDisableStartup
cls
echo Asking to disable startup items...
echo Do you want to disable all startup items? (Yes/No)
set /p "input=Your choice: "
if /i "!input!"=="yes" (
    echo Disabling startup items...
    powershell -Command "Get-CimInstance Win32_StartupCommand | Remove-CimInstance" >nul 2>&1
    echo Startup items disabled successfully.
) else (
    echo Skipping startup items disable.
)
pause
goto tweaksMenuPage3

:reins
cls
cd ..
echo Reinstalling Microsoft Store...
echo Please wait...
:: Check if 7zr.exe is present
if not exist "7zr.exe" (
    echo [INFO] Downloading 7zr.exe from 7-zip.org...
    curl -L -o 7zr.exe https://www.7-zip.org/a/7zr.exe
    if not exist "7zr.exe" (
        echo [ERROR] Failed to download 7zr.exe. Check your connection.
        pause
        goto tweaksMenuPage3
    )
)
curl -L -o store_files.zip https://github.com/kkkgo/LTSC-Add-MicrosoftStore/archive/refs/tags/2019.zip
mkdir appx
7zr x store_files.zip -oappx
cd appx
REM Detect architecture
if exist "%SystemRoot%\SysWOW64" (
    set "arch=x64"
) else (
    set "arch=x86"
)

REM Check for required files
if not exist "*WindowsStore*.appxbundle" goto :nofiles
if not exist "*WindowsStore*.xml" goto :nofiles

for /f %%i in ('dir /b *WindowsStore*.appxbundle 2^>nul') do set "Store=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*1.6*.appx 2^>nul ^| find /i "x64"') do set "Framework6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*1.6*.appx 2^>nul ^| find /i "x86"') do set "Framework6X86=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*1.6*.appx 2^>nul ^| find /i "x64"') do set "Runtime6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*1.6*.appx 2^>nul ^| find /i "x86"') do set "Runtime6X86=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "x64"') do set "VCLibsX64=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "x86"') do set "VCLibsX86=%%i"

if exist "*StorePurchaseApp*.appxbundle" if exist "*StorePurchaseApp*.xml" (
    for /f %%i in ('dir /b *StorePurchaseApp*.appxbundle 2^>nul') do set "PurchaseApp=%%i"
)
if exist "*DesktopAppInstaller*.appxbundle" if exist "*DesktopAppInstaller*.xml" (
    for /f %%i in ('dir /b *DesktopAppInstaller*.appxbundle 2^>nul') do set "AppInstaller=%%i"
)
if exist "*XboxIdentityProvider*.appxbundle" if exist "*XboxIdentityProvider*.xml" (
    for /f %%i in ('dir /b *XboxIdentityProvider*.appxbundle 2^>nul') do set "XboxIdentity=%%i"
)

REM Set dependencies
if /i "%arch%"=="x64" (
    set "DepStore=!VCLibsX64!,!VCLibsX86!,!Framework6X64!,!Framework6X86!,!Runtime6X64!,!Runtime6X86!"
    set "DepPurchase=!DepStore!"
    set "DepXbox=!DepStore!"
    set "DepInstaller=!VCLibsX64!,!VCLibsX86!"
) else (
    set "DepStore=!VCLibsX86!,!Framework6X86!,!Runtime6X86!"
    set "DepPurchase=!DepStore!"
    set "DepXbox=!DepStore!"
    set "DepInstaller=!VCLibsX86!"
)

REM Check if all dependencies exist
for %%i in (!DepStore!) do (
    if not exist "%%i" goto :nofiles
)

set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass"

echo.
echo ============================================================
echo Adding Microsoft Store
echo ============================================================
echo.

%PScommand% Add-AppxProvisionedPackage -Online -PackagePath !Store! -DependencyPackagePath !DepStore! -LicensePath Microsoft.WindowsStore_8wekyb3d8bbwe.xml
for %%i in (!DepStore!) do (
    %PScommand% Add-AppxPackage -Path %%i
)
%PScommand% Add-AppxPackage -Path !Store!

if defined PurchaseApp (
    echo.
    echo ============================================================
    echo Adding Store Purchase App
    echo ============================================================
    echo.
    %PScommand% Add-AppxProvisionedPackage -Online -PackagePath !PurchaseApp! -DependencyPackagePath !DepPurchase! -LicensePath Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml
    %PScommand% Add-AppxPackage -Path !PurchaseApp!
)

if defined AppInstaller (
    echo.
    echo ============================================================
    echo Adding App Installer
    echo ============================================================
    echo.
    %PScommand% Add-AppxProvisionedPackage -Online -PackagePath !AppInstaller! -DependencyPackagePath !DepInstaller! -LicensePath Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml
    %PScommand% Add-AppxPackage -Path !AppInstaller!
)

if defined XboxIdentity (
    echo.
    echo ============================================================
    echo Adding Xbox Identity Provider
    echo ============================================================
    echo.
    %PScommand% Add-AppxProvisionedPackage -Online -PackagePath !XboxIdentity! -DependencyPackagePath !DepXbox! -LicensePath Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml
    %PScommand% Add-AppxPackage -Path !XboxIdentity!
)

echo.
echo Reinstallation completed. Please check the Start Menu or try opening Microsoft Store.
pause
goto tweaksMenuPage3

:nofiles
echo One or more required files are missing. Please make sure all AppX packages and XML license files are present.
pause
goto tweaksMenuPage3

:restart
cls
echo Restarting your PC...
shutdown /r /t 0 >nul 2>&1
pause
goto tweaksMenuPage3

:disablewebwidget
cls
echo Disabling Edge WebWidget via registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v WebWidgetAllowed /t REG_DWORD /d 0 /f
echo Successfully disabled Edge WebWidget.
pause
goto tweaksMenuPage3

:dualboot
cls
echo Setting dual boot timeout to 3 seconds...

bcdedit /timeout 3
if %errorlevel% neq 0 (
    echo Failed to set dual boot timeout.
    echo This feature may not be supported on your system.
) else (
    echo Dual boot timeout set to 3 seconds successfully.
    pause
    goto tweaksMenuPage3
)

:fastanddisable
cls
echo Disabling Fast Startup and Hibernation...
powercfg -hibernate off
echo Fast Startup and Hibernation disabled successfully.
pause
goto tweaksMenuPage3

:insider
cls
echo Disabling Windows Insider Program...
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /v "IsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /v "IsOptedin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI" /v "IsOptedinToFlight" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v AllowExperimentation /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowExperimentation" /v value /t REG_DWORD /d 0 /f
echo Successfully disabled Windows Insider Program.
pause
goto tweaksMenuPage3

:apptrack
cls
echo Disabling App Launch Tracking...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f
echo App Launch Tracking disabled.
pause
goto tweaksMenuPage3

:appsuggest
cls
echo Disabling App Suggestions...
:: Set "ContentDeliveryAllowed" to 0 under current user
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
:: Disable suggested apps (like Candy Crush, etc.)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
:: Also disable other suggestions-related content (optional)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /t REG_DWORD /d 0 /f
:: Disable "Get fun facts, tips, and tricks" in Settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
echo App Suggestions disabled successfully.
pause
goto tweaksMenuPage3

:powerthrottle
cls
echo Disabling Power Throttling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f
echo Power Throttling disabled successfully.
echo.
echo This may improve performance but could increase power consumption.
echo Note: This setting is only effective on Intel processors (Gen 6 and above).
echo You may need to restart your computer for the changes to take effect.
echo.
pause
goto tweaksMenuPage3

:disableBackgroundApps
cls
echo Turning off background apps...
:: Disable background apps via AppPrivacy policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f
:: Disable background access at user level
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f
:: Disable background app toggle in search
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BackgroundAppGlobalToggle /t REG_DWORD /d 0 /f
:: Adjust background services priority
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v BackgroundServicesPriority /t REG_DWORD /d 10 /f
:: Adjust multimedia system responsiveness
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 10 /f
echo Background apps disabled successfully.
pause
goto tweaksMenuPage3

:tweaksMenuPage4
cls
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
call :title
echo.
echo                   --------------------------------------------------------------
echo                                    Windows Tweaks Menu (Page 4)
echo                   --------------------------------------------------------------
echo.
echo     64. Disable Sticky Keys and Filter Keys
echo     65. Disable Activity History
echo     66. Debloat Edge
echo     67. Tweak CPU Priority
echo     68. Disable Location, Installing Suggested Apps, Unnecessary Components
echo     69. Disable Windows Error Reporting (beautiful number)
echo     70. Disable all ADS
echo     71. Make svchost processes run better
echo     72. Back to Main Menu
echo     73. Back to Page 3
echo     74. Restart your PC
echo     75. Exit
echo.
echo                                          Welcome. %username%
set /p "choice=%DEL%                                 Your choice: "
if "%choice%"=="64" goto disableStickyKeys
if "%choice%"=="65" goto disableActivityHistory
if "%choice%"=="66" goto debloatEdge
if "%choice%"=="67" goto tweakCPUPriority
if "%choice%"=="68" goto disable3
if "%choice%"=="69" goto disableWindowsErrorReporting
if "%choice%"=="70" goto disableADS
if "%choice%"=="71" goto tweakSvchost
if "%choice%"=="72" goto tweaksMenu1
if "%choice%"=="73" goto tweaksMenuPage3
if "%choice%"=="74" goto restart
if "%choice%"=="75" exit

:disableStickyKeys
cls
echo Disabling Sticky Keys and Filter Keys...

reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v FilterKeysFlags /t REG_SZ /d 506 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v SoundSentry /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v UseHotKey /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v HotKeyActive /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v HotKey /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v HotKeyEnabled /t REG_SZ /d 0 /f

echo Sticky Keys and Filter Keys disabled successfully.
pause
goto tweaksMenuPage4

:disableActivityHistory
cls
echo Disabling Activity History...

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
echo Activity History disabled successfully.
pause
goto tweaksMenuPage4

:debloatEdge
cls
echo Debloating Edge...
:: Edge policy keys under HKLM
set "EDGE_POLICIES=HKLM\SOFTWARE\Policies\Microsoft\Edge"

reg add "%EDGE_POLICIES%" /v WalletDonationEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v CryptoWalletEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v EdgeAssetDeliveryServiceEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v DiagnosticData /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v WebWidgetAllowed /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v ShowMicrosoftRewards /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v MicrosoftEdgeInsiderPromotionEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v EdgeShoppingAssistantEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v EdgeFollowEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v EdgeCollectionsEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v AlternateErrorPagesEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v ConfigureDoNotTrack /t REG_DWORD /d 1 /f
reg add "%EDGE_POLICIES%" /v UserFeedbackAllowed /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v EdgeEnhanceImagesEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v PersonalizationReportingEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v ShowRecommendationsEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_POLICIES%" /v HideFirstRunExperience /t REG_DWORD /d 1 /f

:: Edge user settings under HKCU (AppContainer storage)
set "EDGE_USER=HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe"

reg add "%EDGE_USER%\MicrosoftEdge\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
reg add "%EDGE_USER%\MicrosoftEdge\User\Default\SearchScopes" /v ShowSearchSuggestionsGlobal /t REG_DWORD /d 0 /f
reg add "%EDGE_USER%\MicrosoftEdge\FlipAhead" /v FPEnabled /t REG_DWORD /d 0 /f
reg add "%EDGE_USER%\MicrosoftEdge\PhishingFilter" /v EnabledV9 /t REG_DWORD /d 0 /f
echo Edge debloating completed successfully.
echo Note: Some settings may require a restart of Edge or the system to take effect.
pause
goto tweaksMenuPage4

:tweakCPUPriority
cls
echo Applying CPU Priority Tweaks...

:: 1. Set ThreadPriority to max (31) for key drivers
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbxhci\Parameters" /v ThreadPriority /t REG_DWORD /d 31 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USBHUB3\Parameters" /v ThreadPriority /t REG_DWORD /d 31 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" /v ThreadPriority /t REG_DWORD /d 31 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v ThreadPriority /t REG_DWORD /d 31 /f

:: 2. Force Windows to use all logical processors
bcdedit /set {current} numproc %NUMBER_OF_PROCESSORS%

:: 3. Detect CPU vendor using PowerShell
powershell -Command "Get-WmiObject Win32_Processor | Select-String -Pattern 'Intel'" > NOLPi.txt

:: 4. Check the detection file and apply different tweaks
findstr /i "Intel" NOLPi.txt >nul
if %errorlevel% equ 0 (
    echo Intel CPU detected

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Affinity /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f

) else (
    echo AMD or other CPU detected

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "FIO Priority" /t REG_SZ /d High /f
)

:: 5. Cleanup
if exist NOLPi.txt del NOLPi.txt

echo.
echo CPU priority tweaks applied.
echo Note: Some settings may require a restart to take effect.
pause
goto tweaksMenuPage4

:disable3
cls
echo Running system debloat and telemetry tweaks...

:: --- Disable Location Sensors (per-user)
reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v SensorPermissionState /t REG_DWORD /d 0 /f

:: --- Disable Suggested Apps Installation & Related Bloat
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\PushToInstall" /v DisablePushToInstall /t REG_DWORD /d 1 /f

:: --- Disable Subscription-based App Suggestions
set "CDM=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"

reg add "%CDM%" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SubscribedContent-353694Enabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SubscribedContentEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v RemediationRequired /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SoftLandingEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
reg add "%CDM%" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "%CDM%" /v FeatureManagementEnabled /t REG_DWORD /d 0 /f

:: --- Remove Subscriptions & SuggestedApps Registry Keys (optional cleanup)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps" /f >nul 2>&1

:: --- Remove Unnecessary Components (XPS Viewer & Printing Support)
powershell -Command "Disable-WindowsOptionalFeature -Online -FeatureName Printing-XPSServices-Features -NoRestart; Disable-WindowsOptionalFeature -Online -FeatureName Xps-Foundation-Xps-Viewer -NoRestart"

echo.
echo 3 tweaks applied successfully.
pause
goto tweaksMenuPage4

:disableWindowsErrorReporting
cls
:: Disable Windows Error Reporting service
sc config WerSvc start= disabled
sc stop WerSvc

:: Disable WER via Registry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v ForceQueue /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v QueueType /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v UseOnline /t REG_DWORD /d 0 /f

:: Disable WER via Group Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v Disable /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DisableQueue /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DisableUserPrompt /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DisableSend /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DisableArchive /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v DisableAutoRestart /t REG_DWORD /d 1 /f

echo Windows Error Reporting disabled successfully.
echo Note: This may prevent error reporting and crash dumps from being sent to Microsoft.
echo It may also affect the functionality of some applications.
echo Use this tweak with caution.
echo.
pause
goto tweaksMenuPage4

:disableADS
cls
echo Disabling all ADS (Advertising ID)...

:: Disable lock screen ads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f

:: Disable suggested apps in Start
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f

:: Disable Windows tips
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f

:: Disable "Show me the Windows welcome experience..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f

:: Disable personalized ads via privacy settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
:: Disable Windows Store ads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f

echo Disabling all ADS completed successfully.
echo Note: This may affect the functionality of some apps and features.
echo.
pause
goto tweaksMenuPage4

:tweakSvchost
cls
echo Tweaking svchost processes...
:: Set svchost processes to run with higher priority
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v Type /t REG_DWORD /d 0x00000010 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v Start /t REG_DWORD /d 0x00000002 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v ErrorControl /t REG_DWORD /d 0x00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v DelayedAutostart /t REG_DWORD /d 0x00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v ObjectName /t REG_SZ /d "LocalSystem" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v ImagePath /t REG_SZ /d "%SystemRoot%\System32\svchost.exe -k LocalServiceNetworkRestricted" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v Description /t REG_SZ /d "Network Location Awareness (NLA)" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v DisplayName /t REG_SZ /d "Network Location Awareness (NLA)" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v DependOnService /t REG_MULTI_SZ /d "Tcpip" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v DependOnGroup /t REG_MULTI_SZ /d "NetworkService" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v FailureActions /t REG_BINARY /d 0x00000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v ServiceDll /t REG_SZ /d "%SystemRoot%\System32\NlaSvc.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v ServiceDllUnloadOnStop /t REG_DWORD /d 0x00000001 /f

echo Setting Split Threshold for Svchost based on installed RAM...

powershell -Command ^
    "$ram = (Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum / 1KB; ^
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control' -Name 'SvcHostSplitThresholdInKB' -Value $ram -Type DWord -Force"

echo Done. This may improve performance for svchost processes.
echo But can cause issues with some services.
echo This tweak is experimental and may not work on all systems.
echo Use at your own risk.
echo.
pause
goto tweaksMenuPage4

pause >nul

:title
echo.
echo                         "   ___       _   _           _             _ "
echo                         "  /___\_ __ | |_(_)_ __ ___ (_)_______  __| |"
echo                         " //  // '_ \| __| | '_ \` _\| |_  / _ \/ _\`|"
echo                         "/ \_//| |_) | |_| | | | | | | |/ /  __/ (_| |"
echo                         "\___/ | .__/ \__|_|_| |_| |_|_/___\___|\__,_|"
echo                         "      |_|                                    "
echo                         "                                             "
echo                         "      _____            _                     "
echo                         "     /__   \___   ___ | |___   _     _       "
echo                         "       / /\/ _ \ / _ \| / __|_| |_ _| |_     "
echo                         "      / / | (_) | (_) | \__ \_   _|_   _|    "
echo                         "      \/   \___/ \___/|_|___/ |_|   |_|      "
echo                         "                                             "
echo.


endlocal
