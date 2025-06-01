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

@echo off
REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")
REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
cls
echo.
echo    ------------ YOU ARE RUNNING AN UNSTABLE BUILD ------------
echo    This build is not recommended for production use.
echo    It is intended for testing and development purposes only.
echo    Please use at your own risk.
echo.
echo    Detected: You are running this unstable build directly from the source code.
echo    This version may contain experimental features, incomplete tweaks, or bugs.
echo    For the latest stable release, visit: https://github.com/NammIsADev/OptimizedToolsPlusPlus/releases
echo.
echo     Press [Enter] to continue. 
echo    ------------------------------------------------------------
echo.
pause >nul
cls
setlocal EnableDelayedExpansion
call :title
echo.
echo                                  %COL%[33mA litte warning for you^^!%COL%[0m
echo.
echo                     OptimizedTools++ only supports Windows 10 or newer.
echo                          %COL%[31mPlease run it on a compatible version.%COL%[0m
echo                 If you are running Windows 8 or older, please upgrade your OS.
echo.
echo                                   Proceed with caution^^!
echo                                  %COL%[32mPress Enter to continue.%COL%[0m
echo.
pause >nul

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

REM Save the current directory and download required files
set CURRENT_DIR=%~dp0
cd %CURRENT_DIR%

mkdir bin
echo [Info] Downloading required files...

curl -L -o bin/Button.bat https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/bin/Button.bat
curl -L -o bin/GetInput.exe https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/bin/GetInput.exe
curl -L -o bin/batbox.exe https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/bin/batbox.exe

REM Change to the 'bin' directory within the current directory
cd /d %CURRENT_DIR%bin

:update
cls
echo.
echo                   --------------------------------------------------------------
echo                                        Check for updates
echo                   --------------------------------------------------------------
echo                        Warning: Unstable builds don't have a stable updater.
echo                                     Checking for new updates...
echo                                           Please wait...
echo.

:: Download the latest version info
curl -s -o "%temp%\check_unstable.txt" https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/update/check_unstable.txt
ping -n 5 localhost > nul

:: Read the file content
set /p fileContent=<%temp%\check_unstable.txt

:: Check the content and decide the action
if "!fileContent!"=="1.5+unstable" (
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
    start "" "https://github.com/NammIsADev/OptimizedToolsPlusPlus/releases/"
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
goto launch1

:launch1
cls
title OptimizedTools++: Select Language
echo.
echo                   --------------------------------------------------------------
echo                                          Select Language
echo                   --------------------------------------------------------------
echo.
echo    1. English
echo    2. Vietnamese
echo    More languages coming soon...
echo.
set /p "lang=%DEL%                                          Your choice: "
if "%lang%"=="1" goto warn
if "%lang%"=="2" goto vn
goto launch1

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
set /p "input=%DEL%                                       Your input:
if /i "!input!" neq "yes" goto warn
reg add "HKCU\Software\opt" /v "Disclaimer" /f >nul 2>&1
goto tweakcat

:tweakcat
cls
title OptimizedTools++
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
call :title
echo.
echo                   --------------------------------------------------------------
echo                                          Tweaks Category
echo                   --------------------------------------------------------------
echo.
echo    1. System Performance, UI Enhancements                  2. Windows Customizations
echo    3. Uninstall, Debloat                                   4. Security, Privacy
echo    5. Networking, Performance Tweaks                       6. Gaming, Hardware Optimizations
echo    7. Utility, Extras                                      8. Restore, Maintenance Options
echo.
echo                   [9] Exit [0] Restart [r] Restore Point [s] Settings [d] Debug
echo. 
echo                                        1.3+unstable
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto systemperf-uienchant
if "%choice%"=="2" goto windowscustomizations
if "%choice%"=="3" goto uninstall-debloat
if "%choice%"=="4" goto security-privacy
if "%choice%"=="5" goto networking-performance
if "%choice%"=="6" goto gaming-hardware
if "%choice%"=="7" goto utility-extras
if "%choice%"=="8" goto restore-maintenance
if "%choice%"=="9" exit
if "%choice%"=="0" goto restart
if "%choice%"=="r" goto restorepoint1
if "%choice%"=="s" goto settings
if "%choice%"=="d" goto debug
goto tweakcat

:restorepoint1
cd ..
cd bin
goto restorepoint

:systemperf-uienchant
cls
title OptimizedTools++: System Performance, UI Enhancements
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                 System Performance, UI Enhancements
echo                   --------------------------------------------------------------
echo.
echo     1. Disable Startup Delay
echo     2. Enable Dark Mode
echo     3. Enable File Extensions
echo     4. Disable Animations
echo     5. Enable Faster Shutdown
echo     6. Enable Classic Taskbar (may not work on 23H2+)
echo     7. Enable Verbose Boot
echo     8. Disable Background Apps
echo     9. Enable Ultimate Performance Plan
echo     10. Enable Large System Cache
echo     11. Optimize GPU Scheduling (Intel/AMD)
echo     12. Auto Tweaks for Desktop/Laptop
echo     13. Disable Unnecessary Windows Services
echo     14. Align Taskbar to Left (Windows 11+ only)
echo     15. Disable NTFS Indexing
echo     16. Disable Superfetch (Caution: affect performance)
echo     17. Disable Startup Items
echo     18. Go back main menu
echo     19. Next page
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto disableStartupDelay
if "%choice%"=="2" goto enableDarkMode
if "%choice%"=="3" goto enableFileExtensions
if "%choice%"=="4" goto disableAnimations
if "%choice%"=="5" goto fasterShutdown
if "%choice%"=="6" goto enableClassicTaskbar
if "%choice%"=="7" goto enableVerboseBoot
if "%choice%"=="8" goto disableBackgroundApps
if "%choice%"=="9" goto enableUltimatePerformance
if "%choice%"=="10" goto enableLargeSystemCache
if "%choice%"=="11" goto optimizeGPUScheduling
if "%choice%"=="12" goto autoTweaks
if "%choice%"=="13" goto disableUnnecessaryServices
if "%choice%"=="14" goto alignTaskbarLeft
if "%choice%"=="15" goto disableNTFSIndexing
if "%choice%"=="16" goto disableSuperfetch
if "%choice%"=="17" goto askDisableStartup
if "%choice%"=="18" goto tweakcat
if "%choice%"=="19" goto systemperf-uienchantpage2
goto systemperf-uienchant

:systemperf-uienchantpage2
cls
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
call :title
echo.
echo                   --------------------------------------------------------------
echo                               System Performance, UI Enhancements (P2)
echo                   --------------------------------------------------------------
echo.
echo     20. Disable Hibernation and Fast Startup
echo     21. Disable Power Throttling (Intel Gen 6+)
echo     22. Tweak CPU Priority
echo     23. Make svchost processes run better
echo     24. Disable Webview/Webwidget
echo     25. Disable Action Center
echo     26. Go back page 1
echo     27. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="20" goto fastanddisable
if "%choice%"=="21" goto powerthrottle
if "%choice%"=="22" goto tweakCPUPriority
if "%choice%"=="23" goto tweakSvchost
if "%choice%"=="24" goto disableWebwidget
if "%choice%"=="25" goto disableActionCenter
if "%choice%"=="26" goto systemperf-uienchant
if "%choice%"=="27" goto tweakcat
goto systemperf-uienchantpage2

:windowscustomizations
cls
title OptimizedTools++: Windows Customizations
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                      Windows Customizations
echo                   --------------------------------------------------------------
echo.
echo    1. Set Classic Right-Click Menu (Windows 11+)
echo    2. Add delay to menu boot (3 seconds, only dual boot)
echo    3. Disable Sticky Keys and Filter Keys
echo    4. Hide Widgets and Weather (cause bug, disable in taskbar first)
echo    5. Disable Search in Taskbar
echo    6. Disable Fullscreen Optimizations
echo    7. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto setClassicRightClickMenu
if "%choice%"=="2" goto dualboot
if "%choice%"=="3" goto disableStickyKeys
if "%choice%"=="4" goto hideWidgetsWeather
if "%choice%"=="5" goto disableSearchTaskbar
if "%choice%"=="6" goto disableFullscreenOptimizations
if "%choice%"=="7" goto tweakcat
goto windowscustomizations

:uninstall-debloat
cls
title OptimizedTools++: Uninstall, Debloat
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                        Uninstall, Debloat
echo                   --------------------------------------------------------------
echo.
echo     1. Clear Temporary Files
echo     2. Remove Bloatware
echo     3. Debloat Windows 10/11
echo     4. Uninstall OneDrive
echo     5. Uninstall Microsoft Edge (Powered by ShadowWhisperer)
echo     6. Reinstall Microsoft Store
echo     7. Debloat Edge
echo     8. Disable Location, Installing Suggested Apps, Unnecessary Components
echo     9. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto clearTempFiles
if "%choice%"=="2" goto removeBloatware
if "%choice%"=="3" goto debloatWindows
if "%choice%"=="4" goto uninstallOneDrive
if "%choice%"=="5" goto removeEdge
if "%choice%"=="6" goto reins
if "%choice%"=="7" goto debloatEdge
if "%choice%"=="8" goto disable3
if "%choice%"=="9" goto tweakcat
goto uninstall-debloat

:security-privacy
cls
title OptimizedTools++: Security, Privacy
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                         Security, Privacy
echo                   --------------------------------------------------------------
echo.
echo     1. Disable Telemetry
echo     2. Disable Cortana (Old Windows 10)
echo     3. Disable Windows Defender
echo     4. Turn Off Reserved Storage
echo     5. Turn Off Spectre and Meltdown Mitigations (CAUTION)
echo     6. Disable Office Telemetry
echo     7. Disable SmartScreen (Caution: may affect security)
echo     8. Disable Microsoft Store App Updates
echo     9. Disable Windows Insider (Caution: cause bug in Settings app)
echo     10. Disable App Launch Tracking
echo     11. Disable App Suggestions
echo     12. Disable Activity History
echo     13. Disable Windows Error Reporting
echo     14. Disable all ADS
echo     15. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto disableTelemetry
if "%choice%"=="2" goto disableCortana
if "%choice%"=="3" goto disableWindowsDefender
if "%choice%"=="4" goto turnOffReservedStorage
if "%choice%"=="5" goto turnOffSpectreMeltdown
if "%choice%"=="6" goto disableOfficeTelemetry
if "%choice%"=="7" goto disableSmartScreen
if "%choice%"=="8" goto disableStoreAppUpdates
if "%choice%"=="9" goto insider
if "%choice%"=="10" goto apptrack
if "%choice%"=="11" goto appsuggest
if "%choice%"=="12" goto disableActivityHistory
if "%choice%"=="13" goto disableWindowsErrorReporting
if "%choice%"=="14" goto disableADS
if "%choice%"=="15" goto tweakcat
goto security-privacy

:networking-performance
cls
title OptimizedTools++: Networking, Performance Tweaks
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                    Networking, Performance Tweaks
echo                   --------------------------------------------------------------
echo.
echo     1. Optimize Network Performance
echo     2. Disable IPv6
echo     3. Disable Teredo
echo     4. Tweak TCP/IP Settings
echo     5. Flush DNS Cache
echo     6. Change DNS Server
echo     7. Disable QoS Packet Scheduler
echo     8. Disable Network Throttling
echo     9. Disable Network Discovery
echo     10. Enhance System Network (using Network+)
echo     11. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto optimizeNetwork
if "%choice%"=="2" goto disableIPv6
if "%choice%"=="3" goto disableTeredo
if "%choice%"=="4" goto tweakTCPIP
if "%choice%"=="5" goto flushDNS
if "%choice%"=="6" goto changeDNS
if "%choice%"=="7" goto disableQoSPacketScheduler
if "%choice%"=="8" goto disableNetworkThrottling
if "%choice%"=="9" goto disableNetworkDiscovery
if "%choice%"=="10" goto enhanceSystemNetwork
if "%choice%"=="11" goto tweakcat
goto networking-performance

:gaming-hardware
cls
title OptimizedTools++: Gaming, Hardware Optimizations
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                   Gaming, Hardware Optimizations
echo                   --------------------------------------------------------------
echo.
echo     1. NVIDIA GPU Optimization
echo     2. Disable HPET
echo     3. Disable CPU C-States
echo     4. Enable CPU Turbo Boost
echo     5. Enable Hyper Threading
echo     6. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto nvidiaOptimization
if "%choice%"=="2" goto disableHPET
if "%choice%"=="3" goto disableCStates
if "%choice%"=="4" goto enableTurboBoost
if "%choice%"=="5" goto enableHyperThreading
if "%choice%"=="6" goto tweakcat
goto gaming-hardware

:utility-extras
cls
title OptimizedTools++: Utility, Extras
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                         Utility, Extras
echo                   --------------------------------------------------------------
echo     1. Install Useful Apps
echo     2. Activate Windows (Powered by MAS)
echo     3. Disable Microsoft Copilot
echo     4. Patch: Fix Keyboard Layout
echo     5. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto installUsefulApps
if "%choice%"=="2" goto activateWindows
if "%choice%"=="3" goto disableMicrosoftCopilot
if "%choice%"=="4" goto patchKeyboardLayout
if "%choice%"=="5" goto tweakcat
goto utility-extras

:restore-maintenance
cls
title OptimizedTools++: Restore, Maintenance Options
echo %COL%[33m////////////////////////////////////////UNSTABLE BUILD//////////////////////////////////////////////%COL%[0m
echo.
echo                   --------------------------------------------------------------
echo                                    Restore, Maintenance Options
echo                   --------------------------------------------------------------
echo     1. Disable Windows Updates (Caution: may affect security)
echo     2. Restart your PC
echo     3. SFC /scannow
echo     4. DISM /Online /Cleanup-Image /RestoreHealth
echo     5. Start Restore Point
echo     6. Free up Disk Space
echo     7. Chkdsk /f /r C:
echo     8. Go back main menu
echo.
echo                                         Welcome. %username%
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" goto disableWindowsUpdates
if "%choice%"=="2" goto restart
if "%choice%"=="3" goto sfc1
if "%choice%"=="4" goto dism
if "%choice%"=="5" goto startRestorePoint
if "%choice%"=="6" goto freeDiskSpace
if "%choice%"=="7" goto chkdsk2
if "%choice%"=="8" goto tweakcat
goto restore-maintenance

:disableStartupDelay
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f
echo Disabled Startup Delay.
pause
goto systemperf-uienchant

:enableDarkMode
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f
echo Enabled Dark Mode.
pause
goto systemperf-uienchant

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
goto security-privacy

:optimizeNetwork
cls
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f
echo Optimized Network Performance.
pause
goto networking-performance

:disableCortana
cls
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
echo Disabled Cortana.
pause
goto security-privacy

:enableFileExtensions
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
echo Enabled File Extensions.
pause
goto systemperf-uienchant

:disableAnimations
cls
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f
echo Disabled Animations.
pause
goto systemperf-uienchant

:clearTempFiles
cls
del /q /s %temp%\*
echo Cleared Temporary Files.
pause
goto uninstall-debloat

:fasterShutdown
cls
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d 2000 /f
echo Enabled Faster Shutdown.
pause
goto systemperf-uienchant

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
goto uninstall-debloat

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
goto uninstall-debloat

:disableWindowsDefender
cls
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f
echo Disabled Windows Defender.
pause
goto security-privacy

:enableClassicTaskbar
cls
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d 1 /f
echo Enabled Classic Taskbar.
pause
goto systemperf-uienchant

:disableActionCenter
cls
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f
echo Disabled Action Center.
pause
goto systemperf-uienchantpage2

:enableVerboseBoot
cls
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f
echo Enabled Verbose Boot.
pause
goto systemperf-uienchant

:uninstallOneDrive
cls
echo Uninstalling OneDrive...
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Microsoft\OneDrive" /f >nul 2>&1
echo OneDrive uninstalled successfully.
pause
goto uninstall-debloat

:disableFullscreenOptimizations
cls
echo Disabling Fullscreen Optimizations...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo Fullscreen Optimizations disabled successfully.
pause
goto windowscustomizations

:disableMicrosoftCopilot
cls
echo Disabling Microsoft Copilot...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Copilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
echo Microsoft Copilot disabled. You might need to restart Explorer or your computer for the change to take full effect.
pause
goto utility-extras

:disableIPv6
cls
echo Disabling IPv6...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
echo IPv6 disabled. You might need to restart your computer for the changes to take effect.
pause
goto networking-performance

:disableTeredo
cls
echo Disabling Teredo...
netsh interface teredo set state disabled
echo Teredo disabled.
pause
goto networking-performance

:setClassicRightClickMenu
cls
echo Setting classic right-click menu...
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f >nul 2>&1
taskkill /f /im explorer.exe && explorer.exe
echo Classic right-click menu set. 
goto windowscustomizations

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
echo Microsoft Edge uninstalled successfully.
pause
title OptimizedTools++
goto uninstall-debloat

:installUsefulApps
cls
echo Launching XMenu and checking for Chocolatey installation...
echo XMenu is still in development, so it may not work as expected. 
echo Developed by Namm - v1.0
echo.
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
        goto utility-extras
    )
    echo Chocolatey installed successfully.
) else (
    echo Chocolatey is already installed.
)

cls
echo Launching XMenu...
cls
echo debug:XMenuDevEdition1.0
echo please report any bugs to Namm on Github.
echo                   --------------------------------------------------------------
echo                                               Apps List
echo                   --------------------------------------------------------------
echo.
echo       
echo     1. Google Chrome
echo     2. Mozilla Firefox
echo     3. Microsoft Edge
echo     4. Visual C++ Redistributable
echo     5. Python
echo     6. TeamViewer
echo     7. Java SE 8
echo     8. 7-Zip
echo     9. Notepad++
echo    10. Net Framework 4.8
echo    11. Git
echo    12. WinRAR
echo    13. Node.js
echo    14. Malwarebytes
echo    15. CCleaner
echo    16. Visual Studio Code
echo    17. VLC Media Player
echo    18. Go to menu 2
echo    19. Back to main menu
echo.
set /p "choice=%DEL%                                       Your choice: "
if "%choice%"=="1" choco install googlechrome -y
if "%choice%"=="2" choco install firefox -y
if "%choice%"=="3" choco install microsoft-edge -y
if "%choice%"=="4" choco install vcredist140 -y
if "%choice%"=="5" choco install python -y
if "%choice%"=="6" choco install teamviewer -y
if "%choice%"=="7" choco install jre8 -y
if "%choice%"=="8" choco install 7zip -y
if "%choice%"=="9" choco install notepadplusplus -y
if "%choice%"=="10" choco install dotnetfx -y
if "%choice%"=="11" choco install git -y
if "%choice%"=="12" choco install winrar -y
if "%choice%"=="13" choco install nodejs -y
if "%choice%"=="14" choco install malwarebytes -y
if "%choice%"=="15" choco install ccleaner -y
if "%choice%"=="16" choco install vscode -y
if "%choice%"=="17" choco install vlc -y
if "%choice%"=="18" goto xmenu2
if "%choice%"=="19" goto mainmenu


:xmenu2
cls
echo debug:XMenuDevEdition1.0
echo please report any bugs to Namm on Github.
echo                   --------------------------------------------------------------
echo                                           Apps List (P2) 
echo                   --------------------------------------------------------------
echo.
echo       
echo     21. Wireshark
echo     22. PuTTY
echo     23. Dropbox
echo     24. GIMP
echo     25. Spotify
echo     26. Thunderbird
echo     27. Brave 
echo     28. Everything
echo     29. Audacity
echo     30. OBS Studio
echo     31. Go to menu 1
echo     32. Back to main menu
echo.
set /p "choice2=%DEL%                                       Your choice: "
if "%choice2%"=="21" choco install wireshark -y
if "%choice2%"=="22" choco install putty -y
if "%choice2%"=="23" choco install dropbox -y
if "%choice2%"=="24" choco install gimp -y
if "%choice2%"=="25" choco install spotify -y
if "%choice2%"=="26" choco install thunderbird -y
if "%choice2%"=="27" choco install brave -y
if "%choice2%"=="28" choco install everything -y
if "%choice2%"=="29" choco install audacity -y
if "%choice2%"=="30" choco install obs-studio -y
if "%choice2%"=="31" goto installUsefulApps
if "%choice2%"=="32" goto mainmenu

:patchKeyboardLayout
sc config "TabletInputService" start= auto
net start "TabletInputService"
sc config "TextInputManagementService" start= demand
net start "TextInputManagementService"
sc config "eventlog" start= auto
net start "eventlog"
sc config "InputService" start= demand
net start "InputService"
sc config "LxpSvc" start= demand
net start "LxpSvc"
echo Patched successfully, please restart your computer for the changes to take effect.
pause
goto utility-extras

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


:: Set the Ultimate Performance scheme as active
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
if %errorlevel% equ 0 (
    echo Ultimate Performance power plan enabled.
) else (
    echo Failed to enable Ultimate Performance power plan.
    echo This feature might not be supported on your system.
)

echo Power plan changes applied successfully.
pause
goto systemperf-uienchant

:turnOffReservedStorage
cls
echo Turning off reserved storage...
reg add "HKLM\Software\Microsoft\Windows\ReservedStorage" /v "AllowUninstall" /t REG_DWORD /d 1 /f >nul 2>&1
echo Attempting to turn off reserved storage. This might not be effective on all systems and might require further steps or a reboot.
pause
goto security-privacy

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
goto networking-performance

:flushDNSCache
cls
echo Flushing DNS cache...
ipconfig /flushdns
echo DNS cache flushed successfully.
pause
goto networking-performance

:enableLargeSystemCache
cls
echo Enabling large system cache...
echo Warning: Enabling large system cache can improve performance for certain workloads but may affect system stability.
set /p "enableLargeCache=Enable large system cache now? (y/n): "
if /i "%enableLargeCache%"=="y" (
    reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
    echo Large system cache enabled.
    pause
    goto systemperf-uienchant
) else (
    echo Skipping large system cache.
    goto systemperf-uienchant
)

:optimizeGPUScheduling
cls
echo Optimizing GPU scheduling...
reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
echo Hardware-accelerated GPU scheduling enabled. You might need to restart your computer.
pause
goto systemperf-uienchant

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
goto security-privacy

:nvidiaOptimization
cls
echo Optimizing NVIDIA GPU settings...
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerLevel" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\Software\NVIDIA Corporation\Global\NvCplApi\Policies" /v "PowerMizerLevelAC" /t REG_DWORD /d 0 /f >nul 2>&1
echo NVIDIA GPU settings optimized successfully.
pause
goto gaming-hardware

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
goto systemperf-uienchant

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
goto utility-extras

:disableHPET
cls
echo Disabling HPET...
bcdedit /set useplatformclock false
echo HPET disabled successfully.
pause
goto gaming-hardware

:enhanceSystemNetwork
cls
echo Enhancing system and network performance...
netsh int tcp set global autotuninglevel=normal
netsh int tcp set global rss=enabled
reg add "HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d 3 /f
echo System and network performance enhanced successfully.
pause
goto networking-performance

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
goto systemperf-uienchant

:disableOfficeTelemetry
cls
echo Disabling Office telemetry...
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Telemetry" /v "DisableTelemetry" /t REG_DWORD /d 1 /f
echo Office telemetry disabled successfully.
pause
goto security-privacy

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
goto networking-performance

:disableWindowsUpdates
cls
echo Disabling Windows Updates...
sc config wuauserv start= disabled >nul 2>&1
sc stop wuauserv >nul 2>&1
echo Windows Updates disabled successfully.
pause
goto restore-maintenance

:alignTaskbarLeft
cls
echo Aligning Taskbar to Left...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul 2>&1
echo Taskbar aligned to the left successfully.
pause
goto systemperf-uienchant

:disableNTFSIndexing
cls
echo Disabling NTFS Indexing...
fsutil behavior set disablelastaccess 1 >nul 2>&1
echo NTFS Indexing disabled successfully.
pause
goto systemperf-uienchant

:disableSmartScreen
cls
echo Disabling SmartScreen...
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
echo SmartScreen disabled successfully.
pause
goto security-privacy

:disableSuperfetch
cls
echo Disabling Superfetch...
sc config SysMain start= disabled >nul 2>&1
sc stop SysMain >nul 2>&1
echo Superfetch disabled successfully.
pause
goto systemperf-uienchant

:disableStoreAppUpdates
cls
echo Disabling Microsoft Store App Updates...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo Microsoft Store App Updates disabled successfully.
pause
goto security-privacy

:sfc1
cls
echo Do not run this if you are using a custom Windows build.
echo Do not close the window or it will break your Windows installation.
echo This will take a while. Do you want to continue? (y/n)
set /p "input=Your choice: "
if /i "!input!"=="y" (
    echo Running System File Checker (SFC)...
    sfc /scannow
    if %errorlevel% neq 0 (
        echo SFC scan failed. Please check the logs for more details.
        pause
        goto restore-maintenance
    ) else (
        echo SFC scan completed successfully. No integrity violations found.
        echo You may need to restart your computer for the changes to take effect.
        pause
        goto restore-maintenance
    )
) else (
    echo Skipping SFC scan.
    goto restore-maintenance
)

:dism
cls
echo Do not run this if you are using a custom Windows build.
echo Do not close the window or it will break your Windows installation.
echo This will take a while. Do you want to continue? (y/n)
set /p "input=Your choice: "
if /i "!input!"=="y" (
    echo Running DISM to repair Windows image...
    dism /Online /Cleanup-Image /RestoreHealth
    if %errorlevel% neq 0 (
        echo DISM scan failed. Please check the logs for more details.
        pause
        goto restore-maintenance
    ) else (
        echo DISM scan completed successfully. No integrity violations found.
        echo You may need to restart your computer for the changes to take effect.
        pause
        goto restore-maintenance
    )
) else (
    echo Skipping DISM scan.
    goto restore-maintenance
)

:chkdsk2
cls
echo Chkdsk will check your disk for errors. (C:)
echo Do not close the window or it will break your hardware.
echo This will reboot your PC. Do you want to continue? (y/n)
set /p "input=Your choice: "
if /i "!input!"=="y" (
    echo Running Chkdsk...
    start /wait chkdsk C: /f /r
    shutdown /r /t 0
) else (
    echo Skipping Chkdsk.
    goto restore-maintenance
)

:startRestorePoint
cls
echo Strating restore point ulitites...
rstrui.exe
pause
goto restore-maintenance

:freediskspace
cls
echo Freeing up disk space...
echo This will delete temporary files and system files.
echo Do you want to continue? (y/n) 
set /p "input=Your choice: "
if /i "!input!"=="y" (
    echo Running Disk Cleanup...
    cleanmgr /sagerun:1
    echo Disk Cleanup completed successfully.
    pause
    goto restore-maintenance
) else (
    echo Skipping Disk Cleanup.
    goto restore-maintenance
)

:hideWidgetsWeather
cls
echo Hiding Widgets and Weather...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
echo Widgets and Weather hidden successfully.
pause
goto windowscustomizations

:disableSearchTaskbar
cls
echo Disabling Search in Taskbar...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul 2>&1
echo Search in Taskbar disabled successfully.
pause
goto windowscustomizations

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
goto systemperf-uienchant

:reins
cls
cd ..
echo Reinstalling Microsoft Store...
echo Please wait...
:: Check if 7zr.exe is present
if not exist "7z.exe" (
    echo [INFO] Downloading 7z.exe from OptimizedTools++ repo...
    curl -L -o 7z.exe https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/bin/7z.exe
    if not exist "7z.exe" (
        echo [ERROR] Failed to download 7z.exe. Check your connection.
        pause
        goto uninstall-debloat
    )
)
curl -L -o store_files.zip https://github.com/kkkgo/LTSC-Add-MicrosoftStore/archive/refs/tags/2019.zip
mkdir appx
7z x store_files.zip -oappx
cd appx\LTSC-Add-MicrosoftStore-2019
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
goto uninstall-debloat

:nofiles
echo One or more required files are missing. Please make sure all AppX packages and XML license files are present.
pause
goto uninstall-debloat

:restart
cls
echo Restarting your PC...
shutdown /r /t 0 >nul 2>&1
pause
goto restore-maintenance

:disablewebwidget
cls
echo Disabling Edge WebWidget via registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v WebWidgetAllowed /t REG_DWORD /d 0 /f
echo Successfully disabled Edge WebWidget.
pause
goto systemperf-uienchantpage2

:dualboot
cls
echo Setting dual boot timeout to 3 seconds...

bcdedit /timeout 3
if %errorlevel% neq 0 (
    echo Failed to set dual boot timeout.
    echo This feature may not be supported on your system.
    pause
    goto windowscustomizations
) else (
    echo Dual boot timeout set to 3 seconds successfully.
    pause
    goto windowscustomizations
)

:fastanddisable
cls
echo Disabling Fast Startup and Hibernation...
powercfg -hibernate off
echo Fast Startup and Hibernation disabled successfully.
pause
goto systemperf-uienchantpage2

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
goto security-privacy

:apptrack
cls
echo Disabling App Launch Tracking...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f
echo App Launch Tracking disabled.
pause
goto security-privacy

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
goto security-privacy

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
goto systemperf-uienchantpage2

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
goto systemperf-uienchant

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
goto windowscustomizations

:disableActivityHistory
cls
echo Disabling Activity History...

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f
echo Activity History disabled successfully.
pause
goto security-privacy

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
goto uninstall-debloat

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
goto systemperf-uienchantpage2

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
goto uninstall-debloat

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
goto security-privacy

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
goto security-privacy

:disableQoSPacketScheduler
cls
echo Disabling QoS Packet Scheduler...
:: Disable QoS Packet Scheduler
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DisableQoS" /t REG_DWORD /d 1 /f
:: Disable QoS Packet Scheduler in Group Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "DisableQoS" /t REG_DWORD /d 1 /f
:: Disable QoS Packet Scheduler in Network Adapter settings
netsh interface ip set global qospacket=disabled
:: Disable QoS Packet Scheduler in Windows Firewall
netsh advfirewall firewall set rule group="QoS Packet Scheduler" new enable=no
:: Disable QoS Packet Scheduler in Windows Defender
powershell -Command "Set-NetFirewallRule -DisplayGroup 'QoS Packet Scheduler' -Enabled False"
echo QoS Packet Scheduler disabled successfully.
echo Note: This may improve network performance but could affect some applications.
echo Use this tweak with caution.
echo.
pause
goto networking-performance

:disablenetworkthrottling
cls
echo Disabling Network Throttling...
:: Disable Network Throttling via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d 65534 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d 30 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxFreeTcbs" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxHashTableSize" /t REG_DWORD /d 0 /f
echo Network Throttling disabled successfully.
echo.
pause
goto networking-performance

:disableNetworkDiscovery
cls
echo Disabling Network Discovery...
:: Disable Network Discovery via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "Start" /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "ErrorControl" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "Type" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "DelayedAutostart" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "ObjectName" /t REG_SZ /d "LocalSystem" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "ImagePath" /t REG_SZ /d "%SystemRoot%\System32\svchost.exe -k LocalServiceNetworkRestricted" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "Description" /t REG_SZ /d "Function Discovery Resource Publication" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "DisplayName" /t REG_SZ /d "Function Discovery Resource Publication" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "DependOnService" /t REG_MULTI_SZ /d "Tcpip" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "DependOnGroup" /t REG_MULTI_SZ /d "NetworkService" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "FailureActions" /t REG_BINARY /d 0x00000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "ServiceDll" /t REG_SZ /d "%SystemRoot%\System32\fdrespub.dll" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "ServiceDllUnloadOnStop" /t REG_DWORD /d 0x00000001 /f
echo Network Discovery disabled successfully.
echo.
pause
goto networking-performance

:disableCStates
cls
echo Disabling C-States...
:: Disable C-States via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "CStates" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "CStatesEnabled" /t REG_DWORD /d 0 /f
echo C-States disabled successfully.
echo.
pause
goto gaming-hardware

:enableTurboBoost
echo Enabling Turbo Boost...
:: Enable Turbo Boost via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "TurboBoost" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "TurboBoostEnabled" /t REG_DWORD /d 1 /f
echo Turbo Boost enabled successfully.
echo.
pause
goto gaming-hardware

:enableHyperThreading
echo Enabling Hyper-Threading...
:: Enable Hyper-Threading via registry
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "HyperThreading" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor" /v "HyperThreadingEnabled" /t REG_DWORD /d 1 /f
echo Hyper-Threading enabled successfully.
echo.
pause
goto gaming-hardware

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
goto systemperf-uienchantpage2

pause >nul

:vn
cls
echo.
echo                   --------------------------------------------------------------
echo                                       Download Language Pack
echo                   --------------------------------------------------------------
echo.
echo                                      You choose: Vietnamese
echo                                       Download size: 300kb
echo                       Do you want to download the Vietnamese language pack?
echo.
echo                          1. Yes                   2. No, I will go with English
echo.
set /p "lang=%DEL%                                     	     Your choice: "
if "%lang%"=="1" goto downlanvn
if "%lang%"=="2" goto warn
goto vn

:vn2
cls
echo.
echo                   --------------------------------------------------------------
echo                                       Download Language Pack
echo                   --------------------------------------------------------------
echo.
echo                                      You choose: Vietnamese
echo                                       Download size: 300kb
echo                       Do you want to download the Vietnamese language pack?
echo.
echo                          1. Yes                   2. No, I will go with English
echo.
set /p "lang=%DEL%                                     	     Your choice: "
if "%lang%"=="1" goto downlanvn
if "%lang%"=="2" goto settings
goto vn2

:downlanvn
cls
echo Downloading Vietnamese language pack...
curl -L -o "vi.bat" "https://github.com/NammIsADev/OptimizedToolsPlusPlus/raw/main-development/lang/vi.bat"
echo.
echo Downloading completed.
echo Starting the Vietnamese version...
start cmd /c "vi.bat"
exit
goto vn

:settings
cls
echo.
echo                   --------------------------------------------------------------
echo                                               Settings
echo                   --------------------------------------------------------------
echo.
echo               1. Change language
echo               2. Change color theme (Experimental)
echo               3. Turn on Light mode (Experimental)
echo               4. Switch to Stable
echo               5. Go back main menu
echo.
set /p "settings=%DEL%                                       Your choice: "
if "%settings%"=="1" goto vn2
if "%settings%"=="2" goto theme
if "%settings%"=="3" goto lightmode
if "%settings%"=="4" goto stable
if "%settings%"=="5" goto tweakcat
goto settings

:theme
cls
echo.
echo Please choose a color theme:
echo 1. Default 
echo 2. moreFontLight+
echo 3. Blue
echo 4. Yellow
echo 5. Green
echo 6. Red
echo 7. Purple
echo 8. Cyan
echo 9. Orange
echo 10. Pink
echo 11. Gray
echo.
set /p "theme_choice=Your choice: "
if "%theme_choice%"=="1" (
    cls
    echo Setting Default theme...
    color 07
    echo Default theme enabled.
) else if "%theme_choice%"=="2" (
    cls
    echo Setting Light theme...
    color 0F
    echo Light theme enabled.
) else if "%theme_choice%"=="3" (
    cls
    echo Setting Blue theme...
    color 1F
    echo Blue theme enabled.
) else if "%theme_choice%"=="4" (
    cls
    echo Setting Yellow theme...
    color 6E
    echo Yellow theme enabled.
) else if "%theme_choice%"=="5" (
    cls
    echo Setting Green theme...
    color 2E
    echo Green theme enabled.
) else if "%theme_choice%"=="6" (
    cls
    echo Setting Red theme...
    color 4E
    echo Red theme enabled.
) else if "%theme_choice%"=="7" (
    cls
    echo Setting Purple theme...
    color 5E
    echo Purple theme enabled.
) else if "%theme_choice%"=="8" (
    cls
    echo Setting Cyan theme...
    color 3E
    echo Cyan theme enabled.
) else if "%theme_choice%"=="9" (
    cls
    echo Setting Orange theme...
    color 6E
    echo Orange theme enabled.
) else if "%theme_choice%"=="10" (
    cls
    echo Setting Pink theme...
    color D0
    echo Pink theme enabled.
) else if "%theme_choice%"=="11" (
    cls
    echo Setting Gray theme...
    color 70
    echo Gray theme enabled.
) else (
    cls
    echo Invalid choice. Please try again.
    goto theme
)
echo.
echo Note: The color theme will only apply to the current session.
echo.
pause
goto settings

:lightmode
cls
echo Turning on Light mode...
color F0
echo Light mode enabled.
echo Note: This is an experimental feature and may not work as expected.
echo Revert by: Go to Change color theme and select Default
echo If you encounter any issues, please report them on GitHub.
echo.
pause
goto settings

:stable
cls
echo Downloading Stable...
curl -L -o "stable.bat" "https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/stable.bat"
echo Downloading completed.
echo Switching to Stable...
start cmd /c "stable.bat"
exit
goto stable

:debug
cls
echo.
echo                   --------------------------------------------------------------
echo                                              Debug
echo                   --------------------------------------------------------------
echo.
:: 1. Windows version
echo win32_ver:
ver
echo.

:: 2. System architecture
echo arch: %PROCESSOR_ARCHITECTURE%
echo.

:: 4. Processor name
echo cpu_name:
powershell -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name"
echo.

:: 5. Processor cores
echo cpu_cores:
powershell -Command "(Get-CimInstance Win32_Processor).NumberOfCores"
echo.

:: 6. Processor threads
echo cpu_threads:
powershell -Command "(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors"
echo.

:: 7. RAM size
echo ram_Size:
powershell -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)"
echo.

:: 9. Graphics card
echo gpu:
powershell -Command "Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name"
echo.

:: 11. BIOS version
echo bios_ver:
powershell -Command "Get-CimInstance Win32_BIOS | Select-Object -ExpandProperty SMBIOSBIOSVersion"
echo.

:: 12. Motherboard
echo motherboard:
powershell -Command "Get-CimInstance Win32_BaseBoard | Select-Object -ExpandProperty Product"
echo.

:: 13. System manufacturer
echo sys_manufacturer:
powershell -Command "Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer"
echo.

:: 14. System model
echo sys_model:
powershell -Command "Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty Model"
echo.

:: 16. System serial number
echo sys_sn
powershell -Command "Get-CimInstance Win32_BIOS | Select-Object -ExpandProperty SerialNumber"
echo.

:: 17. System UUID
echo sys_uuid:
powershell -Command "Get-CimInstance Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID"
echo.

:: 20. OptimizedTools++ Version
echo ver: 1.4+unstable
echo.

:: 21. Build Date
echo build_date: 2025-05-31 19:26:08
echo.

:: 23. Build Number
echo build_number: 216-unstable
echo.

pause
goto tweakcat

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
