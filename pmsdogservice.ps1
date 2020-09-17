# Created by github.com/alexandzors
# Created: 2020/08/14 02:09:26
# Last modified: 2020/09/16 18:56:03

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
            Exit
    }
} catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host $ErrorMessage
    Write-Log -LogOutput ($ErrorMessage)
    Exit
}
if (($Config.Script.Timeout) -eq "" -or ![int]) {
    Write-Host "Script.Timeout is not set or is not an integer! Terminating."
    Write-Log -LogOutput ("Script.Timeout is not set or is not an integer! Terminating.")
    Exit
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
    Exit
}     
if (($Config.Script.UseDiscord) -eq $true -or $false){
    Write-Host "Discord: "$Config.Script.UseDiscord
    $SDiscord = ($Config.Script.UseDiscord)
} else {
    Write-Host "Discord logging is not set correctly! [True] or [False] Terminating."
    Write-Log -LogOutput ("Discord logging is not set correctly! [True] or [False] Terminating.")
    Exit
}
Do {
    try {
        if ($SCachet -eq $true){Update-Cachet -ok -token ($Config.Cachet.CachetToken) -id ($Config.Cachet.PlexWatchDogCompID) -compURL ($Config.Cachet.CachetPlexWDUrl) -Verbose}
        [int]$status = Get-PlexStatus -localurl ($Config.Plex.PlexLocalURL) -Verbose
        Write-Host "PlexWatchDog: Returned Status from Get-PlexStatus: "$status
        if (-not $status -eq 200) {
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
    Exit
}
# SIG # Begin signature block
# MIIFoQYJKoZIhvcNAQcCoIIFkjCCBY4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxfQGzjydtZ2EoXgS/2nADLhf
# rU2gggM2MIIDMjCCAhqgAwIBAgIQOmUwlxgUN7RBnpqdR0iHDTANBgkqhkiG9w0B
# AQsFADAgMR4wHAYDVQQDDBVnaXRAYWxleHNndWFyZGlhbi5uZXQwHhcNMjAwOTE3
# MDEzMDQyWhcNMjEwOTE3MDE1MDQyWjAgMR4wHAYDVQQDDBVnaXRAYWxleHNndWFy
# ZGlhbi5uZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCLE06yWZh
# DvkFaOFxZU+Hkg2qsiOgifOdK9DJb28OQ0pQnb9zy3WAy2CEiky0ZMu8o705J2lD
# 0gH3+LoFIRLAitR9dGiaZ0oDbEUYj3OR+VnGPH3mhQ4oeL2jLYmfHjBU+yr5kZLf
# bNu1HypeJIHRqMbd8XUvSl1iPgV0KYseuEGyTqWWvlXQ0ikZBP0LVxhgaCdHgj8q
# W4qo5ZoOyQPwsrtNaUfvaM/kOAFUfORipH7YuJuGLUJlW4lMefR6TZ8w2LUmSjPX
# t37L0nWNWMjdGBOUKpGZHC8MPYzwBCm+EiGM8m7W5i1pLFfTcC7hqWW15HKWDYeO
# Q32X0yg/5lVBAgMBAAGjaDBmMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAgBgNVHREEGTAXghVnaXRAYWxleHNndWFyZGlhbi5uZXQwHQYDVR0O
# BBYEFD+wNEdVkeHwaJ3EeiLapan8MGAMMA0GCSqGSIb3DQEBCwUAA4IBAQBXz6J+
# BwKCrCjuzpt9NGTC//Me4WrSf7I2tmShvglrEOq7ZkUV8opddloeSgy/0x/chNMd
# c7mnuPaxIKJnA2W/klAtbH/eac1c5dxBxOwrpYSzPTdTTtpE4b6RPlZqVikHGGYg
# cIB+Fkr+m6bSTuseuMOi0jbPdiVGxsM+ilE4mq1r4MBS6Q4u1q3Pz2dgnR5hNElA
# QszzlGYJ08TJINxgelqnwakvV/RuBR4pbbksDlHRdxg6hWpH07sIL3ii61jxpIzH
# gCn6ehCRMbEe4LYC7eS2oi3V618lQcikqtoWIec2jXm88+xWoZc3HUbnNifO9PnB
# ic0sJwvsp8HZDDknMYIB1TCCAdECAQEwNDAgMR4wHAYDVQQDDBVnaXRAYWxleHNn
# dWFyZGlhbi5uZXQCEDplMJcYFDe0QZ6anUdIhw0wCQYFKw4DAhoFAKB4MBgGCisG
# AQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFJvk
# fKLkiIAUBV9Q6wxcpK0FdzauMA0GCSqGSIb3DQEBAQUABIIBALzGl9fcCuHikmQX
# srHChyau+55RXc3S9W8OlgH/M7J+gSaTzK1JW+R685sMudasHIe0Q6ECSLM4LBll
# x5Qc5vaMiFxXL2meoEjupj6VdcM5MIVcmZL9oS9KZOhF9k77+mOxps5T2VzPes0V
# LalChALndLXX2XsxQl7e442eAdXDFIv+Xh6+Thpw6dCl3fLTtZ1E5iCAasxGqH87
# 8oubVFZCplaYTvMwF+VQuyeU9tPNSuOVgkEK1VgYN+jtmLz2P2JfJnDWRhuA+ecZ
# BHQAqdDHMqePa6ABRjN0lfdP2HtpC9eKV1dh/6sg0JY/UwKtOQa2wY4rcabzKAKl
# G8zCij4=
# SIG # End signature block
