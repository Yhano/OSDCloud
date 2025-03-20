Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date (Silent)
try {
    Install-Module OSD -Force -ErrorAction Stop
    Import-Module OSD -Force -ErrorAction Stop
    Write-Host "OSD module installed and imported successfully."
} catch {
    Write-Host "Warning: OSD module installation/import failed. Proceeding..." -ForegroundColor Yellow
}

# Prompt for Computer Name
do {
    $ComputerName = (Read-Host "Enter computer name").ToUpper()
    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        $Valid = $true
        Write-Host "Valid computer name entered: $ComputerName"
    } else {
        Write-Host "Invalid name format. Please try again." -ForegroundColor Red
        $Valid = $false
    }
} until ($Valid)

# Prompt for OS Language
do {
    $osLanguage = Read-Host "Please enter the OS language (e.g., en-US, de-DE)"
    
    try {
        Write-Host "Starting OSDCloud deployment with language: $osLanguage..."
        Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI
        $Success = $true
    } catch {
        Write-Host "Invalid OS Language entered. Please try again." -ForegroundColor Red
        $Success = $false
    }
} until ($Success)

Write-Host -ForegroundColor Cyan "Deployment in progress..."

# OS Installation Completed
Write-Host "Operating system installation completed. Adding additional configuration to complete the OSDCloud deployment..."

# Define the XML content for the Unattend.xml file
$UnattendXML = @"
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$ComputerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

# Define the path to save the Unattend.xml file
$UnattendPath = "C:\Windows\Panther\Unattend.xml"

# Save the Unattend.xml file silently
try {
    $UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force
    Write-Host "Unattend.xml file saved to $UnattendPath."
} catch {
    Write-Host "Failed to save Unattend.xml file to $UnattendPath. Error: $_" -ForegroundColor Red
    exit 1
}

# Restart the system after OS deployment
Write-Host "Restarting system in 10 seconds..."
#Start-Sleep -Seconds 10
#wpeutil reboot
