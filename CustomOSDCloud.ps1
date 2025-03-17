Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Prompt user for hostname
$NewComputerName = Read-Host "Enter new computer name"

# Validate the hostname (max 15 characters, alphanumeric)
if ($NewComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "Setting computer name to: $NewComputerName"
    Rename-Computer -NewName $NewComputerName -Force
    # Save hostname for logging
    Set-Content -Path "C:\OSDCloud\ComputerName.txt" -Value $NewComputerName
} else {
    Write-Host "Invalid name. Skipping rename."
     Exit 1
}

# Reboot to apply changes
shutdown -r -t 10

# Restart After OS Deployment
Write-Host "Restarting system..."
Start-Sleep -Seconds 10
wpeutil reboot
