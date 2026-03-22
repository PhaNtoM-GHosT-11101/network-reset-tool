@echo off
title Network Reset Tool

echo =====================================
echo Made by Aditya Priyadarshi
echo =====================================

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator!
    pause
    exit
)

echo Running network reset commands...
echo.

ipconfig /flushdns
ipconfig /registerdns
ipconfig /release
ipconfig /renew
netsh winsock reset

echo.
echo =====================================
echo FNITA
echo =====================================

pause
