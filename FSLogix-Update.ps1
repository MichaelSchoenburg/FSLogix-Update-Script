<#
.SYNOPSIS
    FSLogix-Update-Script

.DESCRIPTION
    PowerShell script which automatically updates FSLogix to the latest version. Intended for use with a RMM tool.

.INPUTS
    Example for variables you have to set through your RMM tool:

    $DownloadPath = "C:\TSD.CenterVision\Software\FSLogix"  # Path where the FSLogix zip file will be downloaded to
    $InstallDay         = "Samstag"                         # Day of the week in German
    $InstallTime        = "04:00"                           # Time in 24h format
    $MinutesTolerance   = 30                                # Tolerance in minutes for the scheduled time check
    $Restart            = 0                                 # 0 = do a restart, 1 = don't do a restart

.OUTPUTS
    Exit Code 0 = Success
    Exit Code 1 = Error
    Exit Code 2 = Warning

.LINK
    GitHub: https://github.com/MichaelSchoenburg/FSLogix-Update-Script

.NOTES
    Author: Michael Schönburg
    Version: v1.0
    Creation: 17.04.2025
    
    This projects code loosely follows the PowerShell Practice and Style guide, as well as Microsofts PowerShell scripting performance considerations.
    Style guide: https://poshcode.gitbook.io/powershell-practice-and-style/
    Performance Considerations: https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.1
#>

#region INITIALIZATION
<# 
    Libraries, Modules, ...
#>

#endregion INITIALIZATION
#region DECLARATIONS
<#
    Declare local variables and global variables
#>

$DownloadUrl = "https://aka.ms/fslogix_download"
$FSLogixZipFileName = "FSLogixAppsSetup.zip"
$FSLogixZipFilePath = Join-Path -Path $DownloadPath -ChildPath $FSLogixZipFileName
$FSLogixExtractedPath = Join-Path -Path $DownloadPath -ChildPath "FSLogixAppsSetup"
$FSLogixSetupExePath = Join-Path -Path $FSLogixExtractedPath -ChildPath "x64\Release\FSLogixAppsSetup.exe"

#endregion DECLARATIONS
#region FUNCTIONS
<# 
    Declare Functions
#>

function Write-ConsoleLog {
    <#
    .SYNOPSIS
    Logs an event to the console.
    
    .DESCRIPTION
    Writes text to the console with the current date (US format) in front of it.
    
    .PARAMETER Text
    Event/text to be outputted to the console.
    
    .EXAMPLE
    Write-ConsoleLog'Subscript XYZ called.'
    
    Long form
    .EXAMPLE
    Log 'Subscript XYZ called.
    
    Short form
    #>

    [alias('Log')]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0)]
        [string]
        $Text
    )

    # Write verbose output
    Write-Output "$( Get-Date -Format 'MM/dd/yyyy HH:mm:ss' ) - $( $Text )"
}

function Check-Scheduled-Time {
    <#
    .SYNOPSIS
        Prüft, ob die aktuelle Zeit dem geplanten Wochentag und der Uhrzeit entspricht.

    .DESCRIPTION
        Prüft, ob die aktuelle Zeit dem durch die Parameter $InstallDay und $InstallTime definierten geplanten Wochentag und der Uhrzeit entspricht.

    .RETURNS
        $true, wenn die aktuelle Zeit dem Zeitplan entspricht, andernfalls $false.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag")]
        [string]
        $Day,

        [Parameter(Mandatory = $false)]
        [string]
        [ValidatePattern('^([01]\d|2[0-3]):([0-5]\d)$')]
        $Time
    )

    $IsScheduledTime = $false

    if ($Day -and $Time) {
        $CurrentDay = Get-Date -Format "dddd"
        $CurrentTime = Get-Date
        try {
            $ScheduledTime = [datetime]::Parse($Time)
        } catch {
            Write-Output "Ungültiges Zeitformat. Verwende HH:mm."
        }

        $TimeDifference = New-TimeSpan -Start $CurrentTime -End $ScheduledTime
        $TotalMinutes = [Math]::Abs($TimeDifference.TotalMinutes)

        if (($CurrentDay -eq $Day) -and ($TotalMinutes -lt $MinutesTolerance)) {
            $IsScheduledTime = $true
        } elseif ($CurrentDay -ne $Day) {
            Write-Output "Heute ist nicht der geplante Tag ($Day)."
        } else {
            Write-Output "Die aktuelle Zeit ($( Get-Date -Date $CurrentTime -Format "HH:mm" )) liegt nicht innerhalb der Toleranz von $MinutesTolerance Minuten um die geplante Zeit ($( Get-Date -Date $ScheduledTime -Format "HH:mm" ))."
        }
    } else {
        Write-Output "Parameter $Day und $Time sind erforderlich."
    }

    if ($IsScheduledTime -eq $true) {
        return $true
    }
}

function Download-File {
    <#
    .SYNOPSIS
        Lädt eine Datei von einer angegebenen URL herunter.

    .DESCRIPTION
        Lädt eine Datei von einer angegebenen URL herunter und speichert sie an einem angegebenen Pfad.

    .PARAMETER Url
        Die URL der Datei, die heruntergeladen werden soll.

    .PARAMETER ZielPfad
        Der Pfad, an dem die Datei gespeichert werden soll.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,
        [Parameter(Mandatory = $true)]
        [string]
        $ZielPfad
    )

    log "Herunterladen von '$Url' nach '$ZielPfad'."
    try {
        # Hiding the progress bar makes the download faster
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $ZielPfad -UseBasicParsing -ErrorAction Stop
        $ProgressPreference = 'Continue'
    } catch {
        log "Fehler beim Herunterladen der Datei: $($_.Exception.Message)"
        throw
    }
}

function Extract-Archive {
    <#
    .SYNOPSIS
        Extrahiert den Inhalt eines Archivs.

    .DESCRIPTION
        Extrahiert den Inhalt eines Archivs (z. B. ZIP) an einen angegebenen Zielpfad.

    .PARAMETER ArchivPfad
        Der Pfad zum Archiv, das extrahiert werden soll.

    .PARAMETER ZielPfad
        Der Pfad, an dem der Inhalt des Archivs extrahiert werden soll.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $ArchivPfad,
        [Parameter(Mandatory = $true)]
        [string]
        $ZielPfad
    )

    log "Extrahieren von '$ArchivPfad' nach '$ZielPfad'."
    try {
        Expand-Archive -LiteralPath $ArchivPfad -DestinationPath $ZielPfad -Force -ErrorAction Stop
    } catch {
        log "Fehler beim Extrahieren des Archivs: $($_.Exception.Message)"
        throw
    }
}

function Install-FSLogix {
    <#
    .SYNOPSIS
        Installiert FSLogix.

    .DESCRIPTION
        Führt das FSLogix-Installationsprogramm mit den angegebenen Argumenten aus.

    .PARAMETER InstallerPfad
        Der Pfad zum FSLogix-Installationsprogramm.

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $InstallerPfad
    )

    log "Installation von FSLogix von '$InstallerPfad'."
    try {
        switch ($Restart) {
            0 { $return = Start-Process -FilePath $InstallerPfad -ArgumentList "/install /quiet" -Wait -PassThru -ErrorAction Stop }
            1 { $return = Start-Process -FilePath $InstallerPfad -ArgumentList "/install /quiet /norestart" -Wait -PassThru -ErrorAction Stop }
        }

        if ($return.ExitCode -ne 0) {
            throw "Installation hat Exit-Code $($return.ExitCode), statt 0."
        } else {
            log "FSLogix erfolgreich installiert."
        }
    } catch {
        log "Fehler bei der Installation von FSLogix: $($_.Exception.Message)"
        throw
    }
}

function Check-For-Restart{
    <#
    .SYNOPSIS
        Prüft, ob ein Neustart erforderlich ist.

    .DESCRIPTION
        Prüft, ob ein Neustart erforderlich ist, indem die Registrierung auf einen ausstehenden Neustart überprüft wird.

    .RETURNS
        $true, wenn ein Neustart erforderlich ist, andernfalls $false.
    #>

    $restartRequired = $false
    $restartKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\PendingRequiredRestart",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations"
    )

    foreach ($key in $restartKeys) {
        if (Test-Path $key) {
            log "Neustart erforderlich aufgrund von: $key"
            $restartRequired = $true
            break
        }
    }

    return $restartRequired
}

function Get-FSLogix-Version {
    <#
    .SYNOPSIS
        Ruft die aktuell installierte FSLogix-Version ab.

    .DESCRIPTION
        Ruft die aktuell installierte FSLogix-Version aus der Registrierung ab.

    .RETURNS
        Die FSLogix-Version als Zeichenfolge oder $null, wenn FSLogix nicht installiert ist.
    #>

    [CmdletBinding()]
    param ()

    $Version = $null

    try {
        $Version = Get-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Apps" -Name "Version" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Version
    } catch {
        throw "Fehler beim Abrufen der FSLogix-Version aus der Registrierung: $($_.Exception.Message)"
    }

    return $Version
}

function Validate-RequiredVariables {
    param(
        $DownloadPath,
        $DownloadUrl,
        $InstallDay,
        $InstallTime,
        $MinutesTolerance,
        $Restart
    )

    $allSet = $true

    if ($DownloadPath -eq $null) {
        Write-Output "`$DownloadPath is not set."
        $allSet = $false
    } else {
        if (($DownloadPath -notmatch '^[A-Za-z]:\\') -and ($DownloadPath -notmatch '^\\\\')) {
            Write-Output "`$DownloadPath '$DownloadPath' is not a valid Windows path format (e.g., C:\\ or \\\\server\\share)."
            $allSet = $false
        } elseif ($DownloadPath -match '[<>"/\|\?\*]') {
            Write-Output "`$DownloadPath '$DownloadPath' contains invalid characters for a Windows path (<>:\/|\?\*)."
            $allSet = $false
        }
    }

    if ($DownloadUrl -eq $null) {
        Write-Output "`$DownloadUrl is not set."
        $allSet = $false
    } else {
        try {
            $Uri = New-Object System.Uri($DownloadUrl)
            if (-not ($Uri.Scheme -in ('http', 'https', 'ftp'))) {
                Write-Output "`$DownloadUrl is not a valid URL scheme (must be http, https, or ftp)."
                $allSet = $false
            }
        } catch {
            Write-Output "`$DownloadUrl is not a valid URL format."
            $allSet = $false
        }
    }

    if ($InstallDay -eq $null) {
        Write-Output "`$InstallDay is not set."
        $allSet = $false
    } elseif (-not ($InstallDay -in ('Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'))) {
        Write-Output "`$InstallDay is not a valid German weekday (Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag)."
        $allSet = $false
    }

    if ($InstallTime -eq $null) {
        Write-Output "`$InstallTime is not set."
        $allSet = $false
    } elseif (-not ($InstallTime -match '^([01]\d|2[0-3]):([0-5]\d)$')) {
        Write-Output "`$InstallTime is not in the valid HH:mm format (00:00 - 23:59)."
        $allSet = $false
    }

    if ($MinutesTolerance -eq $null) {
        Write-Output "`$MinutesTolerance is not set."
        $allSet = $false
    } elseif (-not ([int]::TryParse($MinutesTolerance, [ref]$null))) {
        Write-Output "`$MinutesTolerance is not a valid integer."
        $allSet = $false
    } elseif (($MinutesTolerance -lt 0) -or ($MinutesTolerance -gt 720)) {
        Write-Output "`$MinutesTolerance is not within the valid range (0-720)."
        $allSet = $false
    }

    if ($Restart -eq $null) {
        Write-Output "`$Restart is not set."
        $allSet = $false
    } elseif (-not ([int]::TryParse($Restart, [ref]$null))) {
        Write-Output "`$Restart is not a valid integer."
        $allSet = $false
    } elseif (($Restart -lt 0) -or ($Restart -gt 720)) {
        Write-Output "`$Restart is not within the valid range (0-720)."
        $allSet = $false
    }

    if ($allSet) {
        return $true
    }
}

#endregion FUNCTIONS
#region EXECUTION
<# 
    Script entry point
#>

# Check if all required variables are set
$ValidateVar = Validate-RequiredVariables -DownloadUrl $DownloadUrl -DownloadPath $DownloadPath -InstallDay $InstallDay -InstallTime $InstallTime -MinutesTolerance $MinutesTolerance -Restart $Restart
if ($ValidateVar -ne $true) {
    log "Nicht alle erforderlichen Variablen sind korrekt gesetzt. Das Skript wird nicht ausgeführt."
    log $ValidateVar
    exit 1
}

# Check version and print out
if (Get-FSLogix-Version) {
    log "Aktuell installierte FSLogix Version: $Version"
} else {
    log "Aktuell installierte FSLogix Version: FSLogix ist nicht installiert."
}

# Prüfe, ob die geplante Zeit gültig ist
$ValidateTime = Check-Scheduled-Time -Day $InstallDay -Time $InstallTime
if ($ValidateTime -ne $true) {
    log "Das Skript wird nicht ausgeführt. $ValidateTime"
    exit 0
}

# Erstelle das Download-Verzeichnis, falls es nicht existiert
if (-not (Test-Path $DownloadPath)) {
    try {
        log "Verzeichnis '$DownloadPath' existiert nicht. Erstelle es jetzt."
        $null = New-Item -Path $DownloadPath -ItemType Directory -Force -ErrorAction Stop
    } catch {
        log "Fehler beim Erstellen des Download-Verzeichnisses: $($_.Exception.Message)"
        exit 1
    }
}

try {
    # Datei herunterladen
    Download-File -Url $DownloadUrl -ZielPfad $FSLogixZipFilePath

    # Archiv extrahieren
    Extract-Archive -ArchivPfad $FSLogixZipFilePath -ZielPfad $FSLogixExtractedPath

    # Installiere FSLogix
    Install-FSLogix -InstallerPfad $FSLogixSetupExePath

    # Prüfe auf Neustart
    $RestartRequired = Check-For-Restart

    if (Get-FSLogix-Version) {
        log "Nun installierte FSLogix Version: $Version"
    } else {
        log "Nun installierte FSLogix Version:FSLogix ist nicht installiert."
    }

    if ($RestartRequired) {
        log "FSLogix Update abgeschlossen. Ein Neustart ist erforderlich."
        exit 2
    } else {
        log "FSLogix Update erfolgreich abgeschlossen."
        exit 0
    }
} catch {
    # Fehlerbehandlung
    log "Allgemeiner Fehler: $($_.Exception.Message)"
    exit 1
} finally {
    # Bereinigung
    if (Test-Path $FSLogixZipFilePath) {
        try {
            log "Lösche heruntergeladene Datei '$FSLogixZipFilePath'."
            Remove-Item -Path $FSLogixZipFilePath -Force -ErrorAction Stop
        } catch {
             log "Fehler beim Löschen der heruntergeladenen Datei: $($_.Exception.Message)"
        }
    }

    if (Test-Path $FSLogixExtractedPath -PathType Container) {
        try {
            log "Lösche extrahierte Dateien unter '$FSLogixExtractedPath'."
            Remove-Item -Path $FSLogixExtractedPath -Recurse -Force -ErrorAction Stop
        } catch {
            log "Fehler beim Löschen der extrahierten Dateien: $($_.Exception.Message)"
        }
    }
}

#endregion EXECUTION
