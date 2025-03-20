Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Define Log Path
$LogFileName = "InitialDeployment_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$LogFilePath = "X:\OSDCloud\Logs\$LogFileName"

# Function to Write Logs
function Write-Log {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    
    # Output to console
    Write-Host $Message -ForegroundColor $Color
    
    # Output to log file
    Add-Content -Path $LogFilePath -Value $LogEntry
}

# Function to Handle Fatal Errors
function Stop-Script {
    param (
        [string]$ErrorMessage
    )
    Write-Log "FATAL ERROR: $ErrorMessage" "Red"
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Ensure OSD Module is Up-to-Date (Silent)
try {
    Install-Module OSD -Force -ErrorAction Stop
    Import-Module OSD -Force -ErrorAction Stop
    Write-Log "OSD module installed and imported successfully." "Green"
} catch {
    Write-Log "Warning: OSD module installation/import failed. Proceeding with deployment..." "Yellow"
}

# Prompt for Computer Name
do {
    $ComputerName = (Read-Host "Enter computer name").ToUpper()
    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        $Valid = $true
        Write-Log "Valid computer name entered: $ComputerName" "Green"
    } else {
        Write-Log "Invalid name format. Please try again." "Red"
        $Valid = $false
    }
} until ($Valid)

# Define valid OS languages
$validLanguages = @(
    "ar-sa", "bg-bg", "cs-cz", "da-dk", "de-de", "el-gr", "en-gb", "en-us",
    "es-es", "es-mx", "et-ee", "fi-fi", "fr-ca", "fr-fr", "he-il", "hr-hr", "hu-hu",
    "it-it", "ja-jp", "ko-kr", "lt-lt", "lv-lv", "nb-no", "nl-nl", "pl-pl", "pt-br",
    "pt-pt", "ro-ro", "ru-ru", "sk-sk", "sl-si", "sr-latn-rs", "sv-se", "th-th", "tr-tr",
    "uk-ua", "zh-cn", "zh-tw"
)

# Prompt for OS Language
do {
    $osLanguage = Read-Host "Please enter the OS language (e.g., en-US, de-DE)"
    if ($validLanguages -contains $osLanguage) {
        Write-Log "Valid OS Language entered: $osLanguage" "Green"
        $Success = $true
    } else {
        Write-Log "Invalid OS Language entered. Please try again." "Red"
        $Success = $false
    }
} until ($Success)

# Start OSDCloud Deployment
Write-Log "Starting OSDCloud deployment with language: $osLanguage..."
try {
    Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI
    Write-Log "OSDCloud deployment started successfully." "Green"
} catch {
    Stop-Script "OSDCloud deployment failed. Error details: $_"
}

Write-Log "Deployment in progress..." "Cyan"

# OS Installation Completed
Write-Log "Operating system installation completed. Adding additional configuration to complete the OSDCloud deployment..."

# Define the Unattend XML content
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

# Save the Unattend.xml file
try {
    $UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force
    Write-Log "Unattend.xml file saved to $UnattendPath." "Green"
} catch {
    Stop-Script "Failed to save Unattend.xml file to $UnattendPath. Error: $_"
}

# Define the destination path for the log file
$DestinationLogPath = "C:\OSDCloud\Logs\"

# Copy log file before restart
Write-Log "Copying log file to $DestinationLogPath..."
try {
    Copy-Item -Path $LogFilePath -Destination $DestinationLogPath -Force
    Write-Log "Log file successfully copied to $DestinationLogPath." "Green"
} catch {
    Stop-Script "Failed to copy log file to $DestinationLogPath. Error: $_"
}

# Restart the system after OS deployment
Write-Log "Restarting system in 10 seconds..."
Start-Sleep -Seconds 10
wpeutil reboot
