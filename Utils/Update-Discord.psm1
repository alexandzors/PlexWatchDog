# Created by github.com/alexandzors
# Created: 2020/08/15 03:19:15
# Last modified: 2020/08/27 01:46:10
Import-Module ".\Utils\Write-Log.psm1"
<#
.SYNOPSIS
    Send messages to Discord via Webhook.
.DESCRIPTION
    This function makes it easy to send embedded webhook messages to Discord.
.EXAMPLE
    PS C:\> Update-Discord -webhookurl 'yourwebhookurl' -msg "Your Message Here"
.EXAMPLE
    PS C:\> Update-Discord -color 215125 -title "PlexWatchDog" -thumbnail "https://img.google.com/image.png" -url "https://github.com/alexandzors/PlexWatchDog" -webhookurl "DISCORDWEBHOOKURLHERE" -msg "This is a test message"
.INPUTS
    -color = Message highlight color [Integer]
    -title = Title of message [String]
    -thumbnail = URL of Thumbnail icon [String]
    -url = URL of message title. [String]
    -webhookurl = Discord webhook URL. [String]
    -msg = Message body. [String]
#>
function Update-Discord {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $color = "4289797",
        [Parameter()]
        [string]
        $title = "PlexWatchDog",
        [Parameter()]
        [string]
        $thumbnail,
        [Parameter()]
        [string]
        $url = "https://github.com/alexandzors/PlexWatchDog",
        [Parameter(Mandatory)]
        [string]
        $webhookuri,
        [Parameter(Mandatory)]
        [string]
        $msg
    )
    Write-Verbose "Update-Discord: Using Webhook URI from config.json: $webhookuri"
    Write-Verbose "Update-Discord: Color = $color, title = $title, url = $url, thumbnail = $thumbnail"
    $time = Get-Date -Format "o"
    [System.Collections.ArrayList]$embedArray = @()
    $thumbnailObject = [PSCustomObject]@{
        url = $thumbnail
    }
    $embedObject = [PSCustomObject]@{
        color = $color
        title = $title
        url = $url
        description = $msg
        thumbnail = $thumbnailObject
        timestamp = $time
    }
    $embedArray.Add($embedObject)
    $PayLoad = [PSCustomObject]@{
        embeds = $embedArray
    }
    Write-Verbose "Update-Discord: Payload Created"
    Write-Verbose "Update-Discord: Sending Payload to Discord API.."
    try {
        Invoke-RestMethod -Uri $webhookuri -Body ($PayLoad | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json' -Verbose
    } catch {
        Write-Verbose "Update-Discord: "$_.Exception
        Write-Log -LogOutput ("Update-Cachet ERROR: " + $_.Exception.Message)
    }
    Write-Verbose "Update-Discord: Payload sent successfully!"
}