@echo off
echo [%DATE% %TIME%] SetupComplete.cmd started >> C:\Windows\Setup\Scripts\SetupComplete.log

:: Log the user running the script
whoami >> C:\Windows\Setup\Scripts\SetupComplete.log

:: Temporarily allow unrestricted execution
powershell -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force" >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1

:: Run SetupComplete.ps1
echo [%DATE% %TIME%] Running SetupComplete.ps1... >> C:\Windows\Setup\Scripts\SetupComplete.log
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\SetupComplete.ps1 >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1

:: Debug - Confirm Rename.ps1 Exists
if exist C:\Windows\Setup\Scripts\Rename.ps1 (
    echo [%DATE% %TIME%] Rename.ps1 exists. Proceeding with execution. >> C:\Windows\Setup\Scripts\SetupComplete.log
) else (
    echo [%DATE% %TIME%] ERROR: Rename.ps1 is missing! >> C:\Windows\Setup\Scripts\SetupComplete.log
    exit /b 1
)

:: Unblock Rename.ps1 to prevent execution issues
echo [%DATE% %TIME%] Unblocking Rename.ps1... >> C:\Windows\Setup\Scripts\SetupComplete.log
powershell -Command "Unblock-File -Path 'C:\Windows\Setup\Scripts\Rename.ps1'" >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1

:: Run Rename.ps1
echo [%DATE% %TIME%] Running Rename.ps1... >> C:\Windows\Setup\Scripts\SetupComplete.log
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\Rename.ps1 >> C:\Windows\Setup\Scripts\Rename.log 2>&1

:: Log execution success/failure
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ERROR: Rename.ps1 failed! >> C:\Windows\Setup\Scripts\SetupComplete.log
) else (
    echo [%DATE% %TIME%] Rename.ps1 executed successfully. >> C:\Windows\Setup\Scripts\SetupComplete.log
)

exit
