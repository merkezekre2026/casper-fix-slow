@echo off
setlocal
title CasperFix - Eski Casper Nirvana hizlandirici

rem Yonetici yetkisi yoksa kendini yonetici olarak yeniden baslat.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Yonetici izni isteniyor...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\CasperFix.ps1" %*
echo.
pause
