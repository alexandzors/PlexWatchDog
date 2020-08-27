# https://www.mroenborg.com/powershell-logging/
Function Write-Log
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [array]$LogOutput
    )
    $LogFolder = [System.IO.Directory]::GetCurrentDirectory() + "\log"
    $Date = Get-Date -UFormat "%d-%m-%Y"
    $LogFile = "$LogFolder\PlexWatchDog_$Date.log"
    if (-not (Test-Path -Path $LogFolder)) {
        [System.IO.Directory]::CreateDirectory($LogFolder)
    }
    $currentDate = (Get-Date -UFormat "%d-%m-%Y")
    $currentTime = (Get-Date -UFormat "%T")
    $logOutput = $logOutput -join (" ")
    Write-Verbose $LogFolder
    Write-Verbose $LogFile
    "[$currentDate $currentTime] $logOutput" | Out-File $LogFile -Append
}