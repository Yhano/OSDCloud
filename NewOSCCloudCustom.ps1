# Set error handling to stop execution on errors
$ErrorActionPreference = 'Stop'

Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
try {
    Install-Module OSD -Force -ErrorAction Stop
    Import-Module OSD -Force -ErrorAction Stop
} catch {
    Write-Host -ForegroundColor Yellow "Warning: Failed to install or import OSD module. Continuing..."
}

# Prompt the user for the computer name
$ComputerName = Read-Host "Enter computer name"

# Validate Hostname
if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "$ComputerName is valid, proceeding with registry update..."
    try {
        reg add HKLM\SYSTEM\Setup /v ComputerName /t REG_SZ /d $ComputerName /f
    } catch {
        Write-Host -ForegroundColor Red "Failed to update registry key. Exiting..."
        Exit 1
    }
} else {
    Write-Host -ForegroundColor Red "Invalid name format. Exiting..."
    Exit 1
}

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
try {
    Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI
} catch {
    Write-Host -ForegroundColor Red "OSDCloud deployment failed. Exiting..."
    Exit 1
}

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
