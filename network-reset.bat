@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ================= CONFIG =================
set "TOOLNAME=NETWORK RESET TOOL"
set "AUTHOR=ADITYA PRIYADARSHI"
set "VERSION=4.0"
set "LOGFILE=%~dp0network_reset_log.txt"
set "MAX_RETRIES=2"

color 0A
title %TOOLNAME% // %AUTHOR%
cls

:: ================= HEADER =================
echo ==============================================================
echo   %TOOLNAME%  v%VERSION%
echo   Author: %AUTHOR%
echo ==============================================================
echo.

:: ================= LOG INIT =================
echo ===== START [%date% %time%] ===== > "%LOGFILE%"

:: ================= ADMIN CHECK =================
call :log "Checking admin privileges"
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :error "Administrator privileges required"
    goto :fatal
)
call :success "Admin privileges confirmed"

:: ================= PRE NETWORK CHECK =================
call :checkInternet "BEFORE"

:: ================= CORE OPERATIONS =================
call :runStep "Flush DNS Cache" "ipconfig /flushdns"
call :runStep "Register DNS" "ipconfig /registerdns"
call :runStep "Release IP" "ipconfig /release"
call :runStep "Renew IP" "ipconfig /renew"
call :runStep "Reset Winsock" "netsh winsock reset"

:: ================= POST CHECK =================
call :checkInternet "AFTER"

:: ================= FINAL =================
echo.
echo ==============================================================
echo   FINAL STATUS SUMMARY
echo ==============================================================
echo   Check log for detailed diagnostics:
echo   %LOGFILE%
echo.

choice /c YN /m "Restart system now?"
if errorlevel 1 shutdown /r /t 5

goto :end

:: ==============================================================
:: FUNCTIONS
:: ==============================================================

:runStep
set "DESC=%~1"
set "CMD=%~2"
set /a attempt=0

:retry
set /a attempt+=1
call :log "Running: %DESC% (Attempt !attempt!)"

%CMD% >> "%LOGFILE%" 2>&1

if %errorlevel% neq 0 (
    call :error "%DESC% failed (Attempt !attempt!)"
    
    if !attempt! LEQ %MAX_RETRIES% (
        call :log "Retrying..."
        timeout /t 2 >nul
        goto retry
    ) else (
        call :error "%DESC% failed after %MAX_RETRIES% retries"
        set "GLOBAL_ERROR=1"
    )
) else (
    call :success "%DESC% completed"
)

goto :eof

:: ------------------------------

:checkInternet
set "PHASE=%~1"
call :log "Checking internet connectivity (%PHASE%)"

ping -n 2 8.8.8.8 >nul 2>&1
if %errorlevel% neq 0 (
    call :error "No connectivity (%PHASE%)"
    set "NET_FAIL=1"
) else (
    call :success "Internet OK (%PHASE%)"
)
goto :eof

:: ------------------------------

:log
echo [%time%] %~1 >> "%LOGFILE%"
echo [*] %~1
goto :eof

:success
echo [%time%] SUCCESS: %~1 >> "%LOGFILE%"
echo [OK] %~1
goto :eof

:error
echo [%time%] ERROR: %~1 >> "%LOGFILE%"
echo [FAIL] %~1
goto :eof

:: ------------------------------

:fatal
echo.
echo ==============================================================
echo   FATAL ERROR - EXECUTION STOPPED
echo ==============================================================
echo Check log file:
echo %LOGFILE%
pause
exit /b 1

:end
echo.
echo Execution complete.
pause
exit /b
