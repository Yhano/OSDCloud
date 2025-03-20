Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

$ComputerName = Read-Host "Enter computer name"

# Validate Hostname
if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "$ComputerName is valid, proceeding updating registry key..."
    reg add HKLM\SYSTEM\Setup /v ComputerName /t REG_SZ /d $ComputerName /f
} else {
    Write-Host "Invalid name. Skipping rename."
    Exit 1
}

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete...


# Pause before restart for verification (uncomment if needed)
# Write-Host "Waiting for 10 seconds before rebooting..."
# Start-Sleep -Seconds 10

# Restart After OS Deployment (uncomment if needed)
# Write-Host "Restarting system..."
# wpeutil reboot