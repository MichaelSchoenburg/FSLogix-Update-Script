# FSLogix Update Script
PowerShell script which automatically updates FSLogix to the latest version. Intended for use with a RMM tool.

## INPUTS
Example for variables you have to set through your RMM tool:

$DownloadPath = "C:\TSD.CenterVision\Software\FSLogix"  # Path where the FSLogix zip file will be downloaded to

$InstallDay         = "Samstag"                         # Day of the week in German

$InstallTime        = "04:00"                           # Time in 24h format

$MinutesTolerance   = 30                                # Tolerance in minutes for the scheduled time check

$Restart            = 0                                 # 0 = do a restart, 1 = don't do a restart

## OUTPUTS
Exit Code 0 = Success
Exit Code 1 = Error
Exit Code 2 = Warning
