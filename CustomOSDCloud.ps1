# This script is for custom OSD Cloud
Write-Host -ForegroundColor Cyan "Starting Ingram Micro OSD Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
try {
    Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
    Install-Module OSD -Force
} catch {
    Write-Host -ForegroundColor Red "Failed to install OSD module. Exiting..."
    Exit 1
}

try {
    Write-Host -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
    Import-Module OSD -Force
} catch {
    Write-Host -ForegroundColor Red "Failed to import OSD module. Exiting..."
    Exit 1
}

# TODO: Spend the time to write a function to do this and put it here
Write-Host -ForegroundColor Cyan "Ejecting ISO"
Write-Warning "That didn't work because I haven't coded it yet!"

# Start-Sleep -Seconds 5
Write-Host -ForegroundColor Red "Invalid computer name format. Only letters, numbers, and dashes allowed."

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Prompt the user for a computer name
$computerName = Read-Host -Prompt "Please enter the computer name"

# Validate name format (optional)
if ($computerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$" ) {
    Write-Host "Using computer name: $computerName"
} else {
    Write-Host "Invalid computer name format. Only letters, numbers, and dashes allowed." -ForegroundColor Red
    Exit 1
}

# Path to Unattend.xml (WinPE environment)
$unattendPath = "X:\Windows\Panther\Unattend.xml"

# Inject the computer name into Unattend.xml
(Get-Content $unattendPath) -replace "<ComputerName>.*?</ComputerName>", "<ComputerName>$computerName</ComputerName>" | Set-Content $unattendPath

Write-Host "Computer name injected into Unattend.xml"

# Store the name in a file for reference (optional)
Set-Content -Path X:\ComputerName.txt -Value $computerName
if (Get-Command wpeutil -ErrorAction SilentlyContinue) {
    wpeutil reboot
} else {
    Write-Host -ForegroundColor Red "wpeutil command not found. Exiting..."
    Exit 1
}
# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Anything I want can go right here and I can change it at any time since it is in the Cloud!!!!!
Write-Host -ForegroundColor Cyan "Starting OSDCloud PostAction ..."

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
