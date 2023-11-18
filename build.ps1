Param (
    [Parameter(Mandatory=$true)]
    [string] $Name,

    [Parameter(Mandatory=$true)]
    [string] $Version
)

. .\pkg\$Name\$Version\invoke.ps1
Invoke-Actions
