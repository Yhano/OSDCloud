Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure the OSD Module is up to date
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

# Define Unattend.xml Path in WinPE
$unattendPath = "X:\Windows\Panther\Unattend.xml"

# Ensure Windows\Panther Directory Exists
if (!(Test-Path "X:\Windows\Panther")) {
    Write-Host "Creating Panther directory..."
    New-Item -Path "X:\Windows\Panther" -ItemType Directory -Force
}

# Create a Custom Unattend.xml
$unattendXML = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$computerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

# Save Unattend.xml in Panther Directory
$unattendXML | Out-File -Encoding utf8 -FilePath $unattendPath
Write-Host "Unattend.xml created successfully!"

# Store Computer Name for Future Use (Optional)
Set-Content -Path "X:\ComputerName.txt" -Value $computerName

# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSName 'Windows 11 23H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Restart After OS Deployment
Write-Host "Restarting system..."
Start-Sleep -Seconds 10
if (Get-Command wpeutil -ErrorAction SilentlyContinue) {
    wpeutil reboot
} else {
    Write-Host "wpeutil command not found. Please ensure you are running in the Windows PE environment." -ForegroundColor Red
}
