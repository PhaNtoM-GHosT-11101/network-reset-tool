@echo off
setlocal enabledelayedexpansion
:: Set terminal color to Electric Aqua
color 0B
title Network Reset Tool // Aditya Priyadarshi

:: -------------------------------------------------------------------------
::    _       _ _ _                ____       _                _               _     _ 
::   / \   __| (_) |_ _   _  __ _ |  _ \ _ __(_)_   _  __ _ __| | __ _ _ __ ___| |__ (_)
::  / _ \ / _` | | __| | | |/ _` || |_) | '__| | | | |/ _` / _` |/ _` | '__/ __| '_ \| |
:: / ___ \ (_| | | |_| |_| | (_| ||  __/| |  | | |_| | (_| \__, | (_| | |  \__ \ | | | |
::/_/   \_\__,_|_|\__|\__, |\__,_||_|   |_|  |_|\__, |\__,_|___/\__,_|_|  |___/_| |_|_|
::                    |___/                     |___/                                  
:: -------------------------------------------------------------------------

:: Administrative privileges check 
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] ERROR: This tool requires administrative privileges.
    echo Please right-click the file and select 'Run as Administrator'.
    pause
    exit /b
)

echo [+] Initializing Network Stack Reset...
echo.

:: Execute core network commands 
echo [1/5] Flushing DNS Cache...
ipconfig /flushdns >nul

echo [2/5] Registering DNS...
ipconfig /registerdns >nul

echo [3/5] Releasing current IP address...
ipconfig /release >nul

echo [4/5] Renewing IP address...
ipconfig /renew >nul

echo [5/5] Resetting Winsock Catalog...
netsh winsock reset >nul

echo.
echo =========================================================================
echo    _____ _   _ ___ _____  _    
echo   ^|  ___^| \ ^| ^|_ _^|_   _^|/ \   
echo   ^| |_  ^|  \^| ^|^| ^|  ^| ^| / _ \  
echo   ^|  _^| ^| ^|\  ^|^| ^|  ^| ^|/ ___ \ 
echo   ^|_^|   ^|_^| \_^|___^| ^|_/_/   \_\
echo =========================================================================
echo Reset Complete. A system restart is highly recommended. 
echo =========================================================================

pause
exit
