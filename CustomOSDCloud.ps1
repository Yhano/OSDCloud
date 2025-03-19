Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI

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

# Ensure $OOBE.cmd are initialized
$OOBECmdPath = "C:\Windows\Setup\Scripts\OOBE.cmd"

# Ensure OOBE.cmd is always updated
if (Test-Path -Path $OOBECmdPath) {
    Write-Host "OOBE.cmd already exists. Overwriting..." -ForegroundColor Yellow
    Remove-Item -Path $OOBECmdPath -Force
}

# Create a fresh SetupComplete.cmd
$OOBECMD = @'
@echo off
setlocal

:: Read the new computer name from the file
set /p NEWNAME=<C:\Windows\Setup\Scripts\NewComputerName.txt
echo New computer name read from file: %NEWNAME% >> C:\Windows\Temp\rename.log

:: Ensure the name is not empty
if "%NEWNAME%"=="" (
    echo Error: New computer name is empty. Exiting... >> C:\Windows\Temp\rename.log
    exit /b 1
)

:: Set the new computer name in the registry before reboot
reg add "HKEY_LOCAL_MACHINE\System\Setup" /v "ComputerName" /t REG_SZ /d %NEWNAME% /f >> C:\Windows\Temp\rename.log

:: Log success
echo Computer name set to %NEWNAME% and will apply on next reboot. >> C:\Windows\Temp\rename.log

endlocal
'@

$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\scripts\oobe.cmd' -Encoding ascii -Force 

Set-Content -Path $OOBECmdPath -Value $OOBECMD -Encoding ASCII -Force

Write-Host "OOBE.cmd successfully created!" -ForegroundColor Green

Start-Sleep -Seconds 60

# Pause before restart for verification (uncomment if needed)
# Write-Host "Waiting for 10 seconds before rebooting..."
# Start-Sleep -Seconds 10

# Restart After OS Deployment (uncomment if needed)
# Write-Host "Restarting system..."
# wpeutil reboot
