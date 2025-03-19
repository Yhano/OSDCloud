Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Set the global OSDCloud variable
$global:MyOSDCloud = [PSCustomObject]@{
    ClearDisk = $true  # Set to $false if you do not want to clear the disk
}

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
Start-Sleep -Seconds 10

$NewComputerName = Read-Host "Enter new computer name"

# Validate Hostname
if ($NewComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "Saving new computer name: $NewComputerName"
    Set-Content -Path "C:\Windows\Setup\Scripts\NewComputerName.txt" -Value $NewComputerName
} else {
    Write-Host "Invalid name. Skipping rename."
    Exit 1
}

Start-Sleep -Seconds 30

# Define source and destination paths
$RenameScriptSource = "X:\OSDCloud\Config\Scripts\SetupComplete\Rename.ps1"
$RenameScriptDestination = "C:\Windows\Setup\Scripts\Rename.ps1"

# Ensure the Windows setup scripts folder exists
if (!(Test-Path "C:\Windows\Setup\Scripts\")) {
    New-Item -ItemType Directory -Path "C:\Windows\Setup\Scripts\" -Force
}

# Copy Rename.ps1 from WinPE (X:\) to the Windows drive (C:\)
if (Test-Path $RenameScriptSource) {
    Copy-Item -Path $RenameScriptSource -Destination $RenameScriptDestination -Force
    Write-Host "Copied Rename.ps1 to C:\Windows\Setup\Scripts\"
} else {
    Write-Host "Rename.ps1 not found in X:\OSDCloud\Config\Scripts\SetupComplete\"
}

Start-Sleep -Seconds 30

# Ensure $RenameCmd and $SetupCompleteCmdPath are initialized
$RenameCmd = "`r`n%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file C:\Windows\Setup\Scripts\Rename.ps1"
$SetupCompleteCmdPath = "C:\Windows\Setup\Scripts\SetupComplete.cmd"

# Ensure SetupComplete.cmd is always updated
if (Test-Path -Path $SetupCompleteCmdPath) {
    Write-Host "SetupComplete.cmd already exists. Overwriting..." -ForegroundColor Yellow
    Remove-Item -Path $SetupCompleteCmdPath -Force
}

# Create a fresh SetupComplete.cmd
$SetupCompleteContent = @"
@echo off
echo [%DATE% %TIME%] SetupComplete.cmd started >> C:\Windows\Setup\Scripts\SetupComplete.log

:: Temporarily allow unrestricted execution
powershell -ExecutionPolicy Unrestricted -Command "Set-ExecutionPolicy Unrestricted -Scope Process -Force" >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1

:: Run SetupComplete.ps1
echo [%DATE% %TIME%] Running SetupComplete.ps1... >> C:\Windows\Setup\Scripts\SetupComplete.log
%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\SetupComplete.ps1 >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1

:: Log execution success/failure
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ERROR: SetupComplete.ps1 failed! >> C:\Windows\Setup\Scripts\SetupComplete.log
) else (
    echo [%DATE% %TIME%] SetupComplete.ps1 executed successfully. >> C:\Windows\Setup\Scripts\SetupComplete.log
)

:: Debug - Confirm Rename.ps1 Exists
if exist C:\Windows\Setup\Scripts\Rename.ps1 (
    echo [%DATE% %TIME%] Rename.ps1 exists. Proceeding with execution. >> C:\Windows\Setup\Scripts\SetupComplete.log
) else (
    echo [%DATE% %TIME%] ERROR: Rename.ps1 is missing! >> C:\Windows\Setup\Scripts\SetupComplete.log
    exit /b 1
)

:: Run Rename.ps1
echo [%DATE% %TIME%] Running Rename.ps1... >> C:\Windows\Setup\Scripts\SetupComplete.log
powershell -ExecutionPolicy Bypass -File C:\Windows\Setup\Scripts\Rename.ps1 >> C:\Windows\Setup\Scripts\Rename.log 2>&1

:: Log execution success/failure
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ERROR: Rename.ps1 failed! >> C:\Windows\Setup\Scripts\SetupComplete.log
) else (
    echo [%DATE% %TIME%] Rename.ps1 executed successfully. >> C:\Windows\Setup\Scripts\SetupComplete.log
)

exit

"@

Set-Content -Path $SetupCompleteCmdPath -Value $SetupCompleteContent -Encoding ASCII -Force

Write-Host "SetupComplete.cmd successfully created!" -ForegroundColor Green

Start-Sleep -Seconds 60

# Pause before restart for verification (uncomment if needed)
# Write-Host "Waiting for 10 seconds before rebooting..."
# Start-Sleep -Seconds 10

# Restart After OS Deployment (uncomment if needed)
# Write-Host "Restarting system..."
# wpeutil reboot
