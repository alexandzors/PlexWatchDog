# Created by github.com/alexandzors
# Created: 2020/08/14 02:09:26
# Last modified: 2020/08/27 13:44:49

<# This script is designed to run on a Windows machine to monitor your Plex Media Server service using vanilla PowerShell.
You do not need to install any modules to make this work. Everything is contained with in this file and supporting files.
This script monitors the following:
- Plex Media Server.exe process [NOT SERVICE]
- Plex Media Server clearWeb UI [Main check]
- Plex Media Server Update service [Main maintenance check]
It can currently log to 3 different locations: 
- Cachet
- Discord via Webhooks
- Log file #>

# Global Config
$LOC = [System.IO.Directory]::GetCurrentDirectory() #+ "\PlexWatchDog"
$global:BaseConfigDirectory = $LOC
$global:BaseConfig = "\config.json"
Write-Host $BaseConfigDirectory$BaseConfig
$ERRORACTION = 0
Import-Module -Name ".\Utils\Write-Log.psm1" -Verbose
Import-Module -Name ".\Utils\Update-Discord.psm1" -Verbose
Import-Module -Name ".\Utils\Update-Cachet.psm1" -Verbose
Import-Module -Name ".\Utils\Get-PlexStatus.psm1" -Verbose
try {
    if (Test-Path -Path $BaseConfigDirectory$BaseConfig) {     
        $global:Config = Get-Content "$BaseConfigDirectory$BaseConfig" -Raw -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue | ConvertFrom-Json -ErrorAction:SilentlyContinue -WarningAction:SilentlyContinue
    } else {
            Write-Host "config.json is missing in $BaseConfigDirectory!"
            Write-Log -LogOutput "config.json is missing in $BaseConfigDirectory!"
            $ERRORACTION = 1
    }
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
    Write-Log -LogOutput ($ErrorMessage)
    $ERRORACTION = 1
}
if (($Config.Script.Timeout) -eq "" -or ![int]) {
    Write-Host "Script.Timeout is not set or is not an integer! Terminating."
    Write-Log -LogOutput ("Script.Timeout is not set or is not an integer! Terminating.")
    $ERRORACTION = 1
} else {
    $global:STimeout = ($Config.Script.Timeout)
    Write-Host "Timeout Set $STimeout"
}
if (($Config.Script.UseCachet) -eq $true -or $false){
    Write-Host "Cachet: "$Config.Script.UseCachet
    $SCachet = ($Config.Script.UseCachet)
} else {
    Write-Host "Cachet logging is not set correctly! [True] or [False] Terminating."
    Write-Log -LogOutput ("Cachet logging is not set correctly! [True] or [False] Terminating.")
    $ERRORACTION = 1
}     
if (($Config.Script.UseDiscord) -eq $true -or $false){
    Write-Host "Discord: "$Config.Script.UseDiscord
    $SDiscord = ($Config.Script.UseDiscord)
} else {
    Write-Host "Discord logging is not set correctly! [True] or [False] Terminating."
    Write-Log -LogOutput ("Discord logging is not set correctly! [True] or [False] Terminating.")
    $ERRORACTION = 1  
}
Do {
    try {
        if ($SCachet -eq $true){Update-Cachet -ok -token ($Config.Cachet.CachetToken) -id ($Config.Cachet.PlexWatchDogCompID) -compURL ($Config.Cachet.CachetPlexWDUrl) -Verbose}
        $status = Get-PlexStatus -localurl ($Config.Plex.PlexLocalURL) -remoteurl ($Config.Plex.PlexRemoteURL) -Verbose
        Write-Host "PlexWatchDog: Returned Status from Get-PlexStatus: "$status
        if (-not $status -eq 200) {
            $UPDATECHECK = Get-Service "Plex Update Service" -ErrorAction SilentlyContinue
            if ($UPDATECHECK.Status -eq "Running") {
                if ($SDiscord -eq $true) {
                    Write-Host "PlexWatchDog: Sending Discord Update."
                    $MSG = Get-Content ($Config.EventMessages.StatusUpdateFile) -Raw | Out-String
                    Update-Discord -color ($Config.Discord.DiscordEmbedUpdateColor) -title ($Config.Discord.DiscordEmbedTitleUpdate) -url ($Config.Discord.DiscordEmbedURL) -webhookuri ($Config.Discord.DiscordWebhookURL) -thumbnail ($Config.Discord.DiscordEmbedThumbnailUpdateURL) -msg $MSG -Verbose
                    Write-Host "PlexWatchDog: Finished Discord Update."
                }     
            } elseif ($UPDATECHECK.Status -eq "Stopped") {
                if ($SCachet -eq $true) {
                    Write-Host "PlexWatchDog: Sending Cachet Update."
                    Update-Cachet -fail -token ($Config.Cachet.CachetToken) -id ($Config.Cachet.PlexComponentID) -compURL ($Config.Cachet.CachetPlexURL) -Verbose
                    Write-Host "PlexWatchDog: Finished Cachet Update."
                } 
                if ($SDiscord -eq $true) {
                    Write-Host "PlexWatchDog: Sending Discord Update."
                    $MSG = Get-Content ($Config.EventMessages.StatusFailFile) -Raw | Out-String
                    Update-Discord -color ($Config.Discord.DiscordEmbedFailColor) -title ($Config.Discord.DiscordEmbedTitleFail) -url ($Config.Discord.DiscordEmbedURL) -webhookuri ($Config.Discord.DiscordWebhookURL) -thumbnail ($Config.Discord.DiscordEmbedThumbnailFailURL) -msg $MSG -Verbose
                    Write-Host "PlexWatchDog: Finished Discord Update."
                }
                Stop-Process -processname "Plex*"; Start-Process 'C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe' -WorkingDirectory "C:\Program Files (x86)\Plex\Plex Media Server\"                      
            }
        }
        if ($status -eq 200) {
            if ($SCachet -eq $true) {
                Write-Host "PlexWatchDog: Sending Cachet Update."
                Update-Cachet -ok -token ($Config.Cachet.CachetToken) -id ($Config.Cachet.PlexComponentID) -compURL ($Config.Cachet.CachetPlexURL) -Verbose
                Write-Host "PlexWatchDog: Finished Cachet Update."
            } 
            if ($SDiscord -eq $true) {
                Write-Host "PlexWatchDog: Sending Discord Update."
                $MSG = Get-Content ($Config.EventMessages.StatusOkayFile) -Raw | Out-String
                Update-Discord -color ($Config.Discord.DiscordEmbedOkColor) -title ($Config.Discord.DiscordEmbedTitleOK) -url ($Config.Discord.DiscordEmbedURL) -webhookuri (($Config.Discord.DiscordWebhookURL) | Out-String) -thumbnail ($Config.Discord.DiscordEmbedThumbnailOkURL) -msg $MSG -Verbose
                Write-Host "PlexWatchDog: Finished Discord Update."
            }
        } else {
            Write-Host "PlexWatchDog: Nothing Happened? End of Check Error"
            Write-Log -LogOutput ("Status Code: $status, Discord Enabled: $SDiscord, Cachet Enabled: $SCachet, Timeout: $STimeout")
            $ERRORACTION = 1
        }
    } catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host $ErrorMessage
        Write-Log -LogOutput ("ERROR - LOOP: $ErrorMessage")
        $ERRORACTION = 1
        if ($SCachet -eq $true){Update-Cachet -fail -token ($Config.Cachet.CachetToken) -id ($Config.Cachet.PlexWatchDogCompID) -compURL ($Config.Cachet.CachetPlexWDUrl) -Verbose}
    } 
    Start-Sleep -Seconds $STimeout
} Until ($ERRORACTION -eq 1) {
    Write-Log -LogOutput ("The script encountered an error during runtime. $ERRORACTION") -Verbose
}