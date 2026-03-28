@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ============================================================================
:: Network Reset Tool - Professional Edition
:: Author: ADITYA PRIYADARSHI
:: Purpose: Reset key Windows network stack components with clear logging.
:: ============================================================================

color 0B
title Network Reset Tool ^|^| Professional Edition

set "APP_NAME=Network Reset Tool"
set "APP_VERSION=2.1"
set "APP_AUTHOR=ADITYA PRIYADARSHI"
set "APP_ORG=FNITA"
set "LOG_FILE=%~dp0network-reset.log"
set "REBOOT_REQUIRED=0"
set /a STEP=0
set /a FAILURES=0

call :printBanner
call :checkAdmin || goto :adminFailure
call :initLog

call :runStep "Flush DNS Cache"          "ipconfig /flushdns"
call :runStep "Register DNS Records"     "ipconfig /registerdns"
call :runStep "Release DHCP Lease"       "ipconfig /release"
call :runStep "Renew DHCP Lease"         "ipconfig /renew"
call :runStep "Reset Winsock Catalog"    "netsh winsock reset" "reboot"
call :runStep "Reset TCP/IP Stack"       "netsh int ip reset"  "reboot"

call :printSummary
pause
exit /b

:printBanner
cls
echo ============================================================================
echo   _   _      _                      _      ____                 _
echo  ^| ^\ ^| ^| ___^| ^|___      _____  _ __^| ^| __ ^|  _ ^\ ___  ___  ___^| ^|_
echo  ^|  ^\^| ^|/ _ ^\ __^\ ^\ /\ / / _ ^\^| '__^| ^|/ /^| ^|_) / _ ^\/ __^|/ _ ^\ __^
echo  ^| ^|^\  ^|  __/ ^|_^| ^\ V  V / (_) ^| ^|  ^|   ^< ^|  _ ^<  __/^\__ ^\  __/ ^|_
echo  ^|_^| ^\_^|^\___^|^\__^| ^\_/^\_/ ^\___/^|_^|  ^|_^|^\_\^|_^| ^\_^\___^|^|___/^\___^|^\__^
echo.
echo  %APP_NAME% v%APP_VERSION%
echo  Created by: %APP_AUTHOR%
echo  Powered by: %APP_ORG%
echo ============================================================================
echo.
exit /b 0

:checkAdmin
net session >nul 2>&1
if %errorlevel% neq 0 exit /b 1
exit /b 0

:adminFailure
echo [ERROR] Administrative privileges are required.
echo         Right-click this script and choose "Run as administrator".
echo.
pause
exit /b 1

:initLog
>"%LOG_FILE%" (
  echo ==============================================================================
  echo %APP_NAME% v%APP_VERSION%
  echo Author: %APP_AUTHOR% ^| Organization: %APP_ORG%
  echo Started: %date% %time%
  echo Host: %COMPUTERNAME% ^| User: %USERNAME%
  echo ==============================================================================
)
call :log "Initialization complete."
echo [INFO] Logging to: %LOG_FILE%
echo.
exit /b 0

:runStep
set /a STEP+=1
set "STEP_NAME=%~1"
set "STEP_CMD=%~2"
set "STEP_FLAG=%~3"

echo [%STEP%/6] %STEP_NAME%...
call :log "STEP %STEP% START - %STEP_NAME%"

cmd /c "%STEP_CMD%" >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    set /a FAILURES+=1
    echo        [FAILED]
    call :log "STEP %STEP% FAIL  - %STEP_NAME% ^| command: %STEP_CMD%"
) else (
    echo        [OK]
    call :log "STEP %STEP% OK    - %STEP_NAME%"
)

if /I "%STEP_FLAG%"=="reboot" set "REBOOT_REQUIRED=1"
exit /b 0

:printSummary
echo.
echo ============================================================================
if %FAILURES% gtr 0 (
    echo [COMPLETE WITH WARNINGS] %FAILURES% step^(s^) reported errors.
    echo Review the log file for details: %LOG_FILE%
    call :log "Completed with warnings. Failures=%FAILURES%"
) else (
    echo [SUCCESS] All network reset steps completed successfully.
    call :log "Completed successfully with zero failures."
)

if "%REBOOT_REQUIRED%"=="1" (
    echo [NOTICE] A system restart is strongly recommended.
)

echo Finished: %date% %time%
echo ============================================================================
exit /b 0

:log
>>"%LOG_FILE%" echo [%date% %time%] %~1
exit /b 0
