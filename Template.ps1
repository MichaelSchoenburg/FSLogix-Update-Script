<#
.SYNOPSIS
    FSLogix-Update-Script

.DESCRIPTION
    PowerShell script which automatically updates FSLogix to the latest version. Intended for use with a RMM tool.

.INPUTS
    

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
    Write-ConsoleLog -Text 'Subscript XYZ called.'
    
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



#endregion FUNCTIONS
#region EXECUTION
<# 
    Script entry point
#>



#endregion EXECUTION
