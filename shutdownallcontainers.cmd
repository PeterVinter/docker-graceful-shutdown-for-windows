@echo off
setlocal EnableDelayedExpansion

:: Set single color for entire script
color 0B

cls

echo.
echo    +------------------------------------------------+
echo    ^|           Docker Graceful Shutdown Tool          ^|
echo    +------------------------------------------------+
echo.

:: Check for PowerShell script
if not exist "%~dp0gracefully_shutdown_all_docker_containers.ps1" (
    echo    [ERROR] Script not found!
    echo    [ERROR] Please check that gracefully_shutdown_all_docker_containers.ps1
    echo    [ERROR] is in the same folder as this CMD file.
    echo.
    pause
    exit /b 1
)

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo    [WARNING] Administrative privileges recommended
    echo    [WARNING] Please run as administrator if you encounter issues
    echo.
    timeout /t 3 >nul
)

echo    Initializing shutdown sequence...
echo.

:: Execute PowerShell script
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0gracefully_shutdown_all_docker_containers.ps1'"

:: Check execution result
if %errorLevel% equ 0 (
    echo.
    echo    +------------------------------------------------+
    echo    ^|               SHUTDOWN SUCCESSFUL                ^|
    echo    +------------------------------------------------+
    echo    √ All containers stopped gracefully
    echo    √ Operation completed without errors
) else (
    echo.
    echo    +------------------------------------------------+
    echo    ^|                 SHUTDOWN FAILED                  ^|
    echo    +------------------------------------------------+
    echo    × Error occurred during shutdown sequence
    echo    × Check PowerShell output for details
)

echo.
echo    Press any key to exit...
pause >nul
endlocal