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

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
Start-Sleep -Seconds 10  # Adjust if necessary

# Display current hostname before renaming
Write-Host -ForegroundColor Yellow "Current computer name BEFORE renaming: $env:COMPUTERNAME"

# Prompt user for hostname
$NewComputerName = Read-Host "Enter new computer name"

# Validate the hostname (max 15 characters, alphanumeric)
if ($NewComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host -ForegroundColor Green "Valid hostname entered: $NewComputerName"
    Write-Host -ForegroundColor Cyan "Renaming computer..."
    
    try {
        Rename-Computer -NewName $NewComputerName -Force -ErrorAction Stop
        Write-Host -ForegroundColor Green "Rename successful! New name: $NewComputerName"
        # Save hostname for logging
        Set-Content -Path "C:\OSDCloud\ComputerName.txt" -Value $NewComputerName
    } catch {
        Write-Host -ForegroundColor Red "Failed to rename the computer! Error: $_"
        Exit 1
    }
} else {
    Write-Host -ForegroundColor Red "Invalid name format. Skipping rename."
    Exit 1
}

# Display current hostname after renaming
Write-Host -ForegroundColor Yellow "Current computer name AFTER renaming (before reboot): $env:COMPUTERNAME"

# Pause before restart for verification
Write-Host "Waiting for 10 seconds before rebooting..."
Start-Sleep -Seconds 10

# Restart After OS Deployment
Write-Host "Restarting system..."
wpeutil reboot
