@echo off
copy updater.bat %temp%\updater.bat
title OptimizedTools++: Preparing...
REM Run as Admin
REM Delete the registry key
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v DummyEntry /f >reg_log.txt 2>&1
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v DummyEntry /t REG_SZ /d 1 >reg_log.txt 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

Mode 100,43
setlocal EnableDelayedExpansion


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
echo.
curl -s -o "%temp%\check.txt" https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/update/check.txt
ping -n 10 localhost > nul

:: Check the content and decide the action
if "!fileContent!"=="2.9.1" (
    echo                         Your version is !newVersion!, you are up to date.
    ping -n 3 localhost > nul
) else (
    echo                           We found a new version. Newer version: !newVersion!
    echo                                      Do you want to update?
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
start /b mp -nodisp -autoexit s.mp3 > NUL 2>&1
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
echo    For any questions and/or concerns, please go to my GitHub: test_link
echo    Type "Yes" to continue: 
set /p "input=%DEL%                                     Your input:
if /i "!input!" neq "yes" goto warn
reg add "HKCU\Software\HoneCTRL" /v "Disclaimer" /f >nul 2>&1
goto mainmenu
goto :eof

:tweaksMenu
cls
call :title
echo.
echo                   --------------------------------------------------------------
echo                                    Windows Tweaks Menu
echo                   --------------------------------------------------------------
echo.
echo     1. Disable Startup Delay
echo     2. Enable Dark Mode
echo     3. Disable Windows Telemetry
echo     4. Optimize Network Performance
echo     5. Disable Cortana
echo     6. Enable File Extensions
echo     7. Disable Animations
echo     8. Clear Temporary Files
echo     9. Enable Faster Shutdown
echo     10. Remove Bloatware
echo     11. Debloat Windows 10/11
echo.
echo.
echo                                           Welcome. %username%
echo %COL%[33m////////////////////////////////////////////TEST BUILD//////////////////////////////////////////////%COL%[0m
set /p "choice=%DEL%                                     Your choice: "

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
goto tweaksMenu

:disableStartupDelay
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f
echo Disabled Startup Delay.
pause
goto tweaksMenu

:enableDarkMode
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f
echo Enabled Dark Mode.
pause
goto tweaksMenu

:disableTelemetry
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
echo Disabled Windows Telemetry.
pause
goto tweaksMenu

:optimizeNetwork
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f
echo Optimized Network Performance.
pause
goto tweaksMenu

:disableCortana
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
echo Disabled Cortana.
pause
goto tweaksMenu

:enableFileExtensions
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
echo Enabled File Extensions.
pause
goto tweaksMenu

:disableAnimations
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d 9012038010000000 /f
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f
echo Disabled Animations.
pause
goto tweaksMenu

:clearTempFiles
del /q /s %temp%\*
echo Cleared Temporary Files.
pause
goto tweaksMenu

:fasterShutdown
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d 2000 /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d 2000 /f
echo Enabled Faster Shutdown.
pause
goto tweaksMenu

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
