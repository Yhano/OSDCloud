Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
try {
    Install-Module OSD -Force
    Import-Module OSD -Force
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
        Write-Host -ForegroundColor Red "Invalid OS Language entered. Please try again."
        $Success = $false  # Keep looping
    }

} until ($Success)

# OS Installation Completed
Write-Host "OS Installation completed, proceeding to the next step..."

#Define minimal Unattend.xml
$UnattendXML = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$ComputerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

# Define the Unattend.xml path
$UnattendPath = "C:\Windows\Panther\Unattend.xml"

# Check if the file exists
if (Test-Path $UnattendPath) {
    Write-Host -ForegroundColor Yellow "Unattend.xml already exists. Overwriting..."
} else {
    Write-Host -ForegroundColor Green "Unattend.xml not found. Creating a new one..."
}

# Save the Unattend.xml file
$UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force
Write-Host -ForegroundColor Green "Unattend.xml created successfully with Computer Name: $ComputerName"

# Restart After OS Deployment
Write-Host "OSDCloud deployment has completed. Restarting system..."
Start-Sleep -Seconds 10
wpeutil reboot
