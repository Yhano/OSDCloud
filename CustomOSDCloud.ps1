Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Prompt for Computer Name
$computerName = Read-Host -Prompt "Enter the new computer name"

# Validate Naming Format
if ($computerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "Using computer name: $computerName"
} else {
    Write-Host "Invalid format! Use 4 letters, (M/W/L), (LAP/WKS/VDI), and 6 digits." -ForegroundColor Red
    Exit 1
}

# Store Computer Name in Registry (Used for First Boot)
Write-Host "Storing computer name for first boot..."
try {
    reg add "HKLM\SOFTWARE\OSDCloud" /v "ComputerName" /t REG_SZ /d $computerName /f
    Write-Host "Computer name stored successfully."
} catch {
    Write-Host "Failed to store computer name in registry: $_" -ForegroundColor Red
    Exit 1
}

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Restart After OS Deployment
Write-Host "Restarting system..."
Start-Sleep -Seconds 10
wpeutil reboot
