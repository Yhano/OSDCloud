# This script is for custom OSD Cloud

Write-Host -ForegroundColor Cyan "Starting Ingram Micro OSD Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
Import-Module OSD -Force

# TODO: Spend the time to write a function to do this and put it here
Write-Host -ForegroundColor Cyan "Ejecting ISO"
Write-Warning "That didn't work because I haven't coded it yet!"
# Start-Sleep -Seconds 5

# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
$osLanguage = (Get-WinSystemLocale).Name
Start-OSDCloud -OSLanguage $osLanguage -OSBuild 24H2 -OSEdition Pro -ZTI

# I need to ensure that the latest drivers will be installed based on the device model
Write-Host -ForegroundColor Cyan "Installing the latest drivers"
Install-OSDDrivers -Model (Get-MyComputerModel) -Force

# Anything I want can go right here and I can change it at any time since it is in the Cloud!!!!!
Write-Host -ForegroundColor Cyan "Starting OSDCloud PostAction ..."

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot