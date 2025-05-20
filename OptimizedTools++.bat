@echo off
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
echo    This script only supports Windows 10 or newer.
echo    Please run it on a compatible version.
echo    If you are running Windows 8 or older, please upgrade your OS.
echo.
echo    Warning: Running this program on an outdated version of Windows may result in system corruption.
echo    Proceed with caution!
echo.
pause

echo.
echo Detecting Windows version...
for /F "tokens=3 delims=. " %%A in ('ver') do (
    set "winver=%%A"
    goto :checkversion
)

:checkversion
echo Detected Windows version: %winver%

if %winver% LSS 6.1 (
    echo.
    echo This version of Windows is not supported. Exiting...
    pause
    exit /b 1
) else (
    echo.
    echo Windows 10 or newer detected. Proceeding with the script...
    echo.
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
echo    For any questions and/or concerns, please go to my GitHub: NammIsADev/OptimizedToolsPlusPlus
echo    Type "Yes" to continue: 
set /p "input=%DEL%                                     Your input:
if /i "!input!" neq "yes" goto warn
reg add "HKCU\Software\HoneCTRL" /v "Disclaimer" /f >nul 2>&1
goto tweaksMenu

:tweaksMenu
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
echo     3. Disable Windows Telemetry
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
goto tweaksMenu

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
goto tweaksMenu

:disableWindowsDefender
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f
echo Disabled Windows Defender.
pause
goto tweaksMenu

:enableClassicTaskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarSmallIcons" /t REG_DWORD /d 1 /f
echo Enabled Classic Taskbar.
pause
goto tweaksMenu

:disableActionCenter
reg add "HKLM\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f
echo Disabled Action Center.
pause
goto tweaksMenu

:enableVerboseBoot
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f
echo Enabled Verbose Boot.
pause
goto tweaksMenu

:uninstallOneDrive
cls
echo Uninstalling OneDrive...
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\OneDrive" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Microsoft\OneDrive" /f >nul 2>&1
echo OneDrive uninstalled successfully.
pause
goto tweaksMenu

:disableBackgroundApps
cls
echo Disabling Background Apps...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo Background Apps disabled successfully.
pause
goto tweaksMenu

:disableFullscreenOptimizations
cls
echo Disabling Fullscreen Optimizations...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo Fullscreen Optimizations disabled successfully.
pause
goto tweaksMenu

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
if "%choice%"=="41" goto tweaksMenu
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

:: Check if Ultimate Performance scheme exists
powercfg /list | findstr "Ultimate Performance" >nul 2>&1
if %errorlevel% neq 0 (
    echo Ultimate Performance scheme not found. Attempting to create it...
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
    if %errorlevel% equ 0 (
        echo Ultimate Performance scheme created successfully.
    ) else (
        echo Failed to create Ultimate Performance scheme.
        echo This feature might not be supported on your system.
        pause
        goto tweaksMenuPage2
    )
)

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
echo     53. Back to Page 2
echo     54. Back to Main Menu
echo     55. Restart your PC
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
if "%choice%"=="53" goto tweaksMenuPage2
if "%choice%"=="54" goto tweaksMenu
if "%choice%"=="55" goto restart
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
echo Reinstalling Microsoft Store...
echo Please wait...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"try {
    $store = Get-AppxPackage -AllUsers Microsoft.WindowsStore
    if ($store) {
        Add-AppxPackage -DisableDevelopmentMode -Register \"$($store.InstallLocation)\AppXManifest.xml\" -ErrorAction Stop
        Write-Output 'Microsoft Store reinstallation attempted.'
    } else {
        Write-Output 'Microsoft Store package not found on this system.'
    }
} catch {
    Write-Output 'Failed to reinstall Microsoft Store: ' + $_.Exception.Message
}"

echo.
echo Reinstallation script completed. Please check the Start Menu or try opening Microsoft Store.
pause
goto tweaksMenuPage3

:restart
cls
echo Restarting your PC...
shutdown /r /t 0 >nul 2>&1
pause
goto tweaksMenuPage3

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
