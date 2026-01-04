@echo off
echo Running migration script...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0MigrateToWwwroot.ps1"
pause
