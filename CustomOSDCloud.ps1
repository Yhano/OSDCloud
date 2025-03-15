# This script is for custom OSD Cloud
Write-Host -ForegroundColor Cyan "Starting Ingram Micro OSD Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
Import-Module OSD -Force

# Function to eject ISO (Placeholder)
function Eject-ISO {
    Write-Host -ForegroundColor Cyan "Ejecting ISO"
    Write-Warning "That didn't work because I haven't coded it yet!"
}

Eject-ISO

# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"

# Get the system locale
$locale = (Get-WinSystemLocale).Name

# Path to the Autopilot offline JSON file
$autopilotJsonPath = ".\AutopilotConfigurationFile.json"  # Adjust this path if the file is in a different directory

Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $locale -OSActivation Volume -AutopilotFile $autopilotJsonPath

# Anything I want can go right here and I can change it at any time since it is in the Cloud!!!!!
Write-Host -ForegroundColor Cyan "Starting OSDCloud PostAction ..."

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
