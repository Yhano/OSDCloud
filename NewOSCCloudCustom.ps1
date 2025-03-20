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

do {
    # Prompt the user for the computer name and force uppercase
    $ComputerName = (Read-Host "Enter computer name").ToUpper()

    # Validate Hostname (Must be uppercase and match specific format)
    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        Write-Host "$ComputerName is valid. Storing for later use..."
        $Valid = $true  # Exit loop
    } else {
        Write-Host -ForegroundColor Red "Invalid name format. Please try again."
        $Valid = $false  # Keep looping
    }

} until ($Valid)

do {
    # Prompt the user for the OS language
    $osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

    # Start OSDCloud Deployment with Custom OS Settings
    Write-Host "Starting OSDCloud deployment with language: $osLanguage..."
    
    try {
        Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI
        $Success = $true  # Exit loop if successful
    } catch {
        Write-Host -ForegroundColor Red "OSDCloud deployment failed. Please try again."
        $Success = $false  # Keep looping
    }

} until ($Success)

# Set the unattended specialize
Write-Host "Applying computer name: $ComputerName"

Set-OSDCloudUnattendSpecialize -ComputerName $ComputerName

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
