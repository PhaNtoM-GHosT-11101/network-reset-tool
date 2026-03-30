@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ================= CONFIG =================
set "TOOLNAME=NETWORK RESET TOOL"
set "AUTHOR=ADITYA PRIYADARSHI (Optimized)"
set "VERSION=5.0"
:: Pattern: I/O Resilience - Write logs to a guaranteed writable directory
set "LOGFILE=%TEMP%\network_reset_log.txt"
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
echo [*] Log initialized at: %LOGFILE%

:: ================= ADMIN CHECK =================
call :log "Checking admin privileges"
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :error "Administrator privileges required."
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
call :runStep "Reset TCP/IP IPv4" "netsh int ip reset"
call :runStep "Reset TCP/IP IPv6" "netsh int ipv6 reset"

:: ================= STABILIZATION PHASE =================
call :log "Waiting 6 seconds for network stack to stabilize..."
:: Pattern: Timing Resilience - Using localhost ping for deterministic delay
ping 127.0.0.1 -n 7 >nul 2>&1

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

choice /c YN /m "Restart system now to apply all changes?"
:: Pattern: Deterministic Evaluation - Errorlevels checked in descending order
if errorlevel 2 goto :end
if errorlevel 1 shutdown /r /t 5

goto :end

:: ==============================================================
:: FUNCTIONS
:: ==============================================================

:runStep
:: Pattern: Scope Isolation - Prevent variable bleed
setlocal
set "DESC=%~1"
set "CMD=%~2"
set /a attempt=0

:retry
set /a attempt+=1
call :log "Running: %DESC% (Attempt !attempt!)"

%CMD% >> "%LOGFILE%" 2>&1

if %errorlevel% neq 0 (
    call :error "%DESC% failed (Attempt !attempt!)"
    
    if !attempt! lss %MAX_RETRIES% (
        call :log "Retrying..."
        ping 127.0.0.1 -n 3 >nul 2>&1
        goto retry
    ) else (
        call :error "%DESC% failed after %MAX_RETRIES% retries"
        :: Pass necessary state variable out of local scope before ending it
        endlocal & set "GLOBAL_ERROR=1"
        goto :eof
    )
) else (
    call :success "%DESC% completed"
)

endlocal
goto :eof

:: ------------------------------

:checkInternet
setlocal
set "PHASE=%~1"
call :log "Checking internet connectivity (%PHASE%)"

ping -n 2 8.8.8.8 >nul 2>&1
if %errorlevel% neq 0 (
    call :error "No connectivity (%PHASE%)"
    endlocal & set "NET_FAIL=1"
) else (
    call :success "Internet OK (%PHASE%)"
    endlocal
)
goto :eof

:: ------------------------------

:log
echo [%time%] [*] %~1 >> "%LOGFILE%"
echo [*] %~1
goto :eof

:success
echo [%time%] [SUCCESS] %~1 >> "%LOGFILE%"
echo [OK] %~1
goto :eof

:error
echo [%time%] [ERROR] %~1 >> "%LOGFILE%"
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
