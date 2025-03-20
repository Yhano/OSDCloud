Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date (Silent)
try {
    Install-Module OSD -Force -ErrorAction SilentlyContinue | Out-Null
    Import-Module OSD -Force -ErrorAction SilentlyContinue | Out-Null
} catch {
    Write-Host -ForegroundColor Yellow "Warning: OSD module installation/import failed. Proceeding..."
}

do {
    # Prompt the user for the computer name and force uppercase
    $ComputerName = (Read-Host "Enter computer name").ToUpper()

    # Validate Hostname (Must be uppercase and match specific format)
    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        $Valid = $true  # Exit loop
    } else {
        Write-Host -ForegroundColor Red "Invalid name format. Please try again."
        $Valid = $false  # Keep looping
    }
} until ($Valid)

do {
    # Prompt the user for the OS language
    $osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

    # Show only deployment progress message
    Write-Host -ForegroundColor Cyan "Deployment in progress..."
    
    try {
        Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI | Out-Null
        $Success = $true  # Exit loop if successful
    } catch {
        Write-Host -ForegroundColor Red "Invalid OS Language entered. Please try again."
        $Success = $false  # Keep looping
    }
} until ($Success)

# OS Installation Completed
Write-Host "Operating system installation completed. Adding additional configuration to complete the OSCloud deployment..."

# Define minimal Unattend.xml
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

# Save the Unattend.xml file silently
$UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force

# Restart After OS Deployment
Start-Sleep -Seconds 10
wpeutil reboot
