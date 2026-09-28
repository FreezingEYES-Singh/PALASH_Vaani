@echo off
rem Starts PALASH-Vaani and keeps it updated from GitHub.
rem Details and options: tools\run-windows.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\run-windows.ps1" %*
echo.
pause
