# PlexWatchDog
A PowerShell script to monitor your Plex Media Server.

# WARNING
This script is still a W.I.P. Use at your own risk!

# To-Do
- Create a xml for Task Scheduler for automatic script running on machine restarts.
- Move check for update service functionality into Get-PlexStatus function. So that `pmsdogservice.ps1` is only reading the config file, sending notifications, and restarting processes/services.
- Figure out a better way to make this script headless and not rely on a Do-Until loop. ;)
- Upgrade `pmsdogservice.ps1` to monitor plex when installed as a system service.
- Upgrade Write-Log function to be usable for constant verbose logging.
- Make the script a service??

# Pre-Notes
This script was built in a PowerShell 7.0.3 environment. So it is recommended to upgrade to PS 7.0.3.

![](img\readme-psversion.jpg)

This repo also contains the requires function files found in `/Utils` so no third party functions are required to be installed.

# How to Use
1. Download the Repo as a ZIP
2. Extract into desired location
3. Edit the `config.json` file to match your environment preferences


|Config   |Value  |
|---------|---------|
|Script.Timeout     | Value in Seconds (default 60) |
|Script.UseCachet   | Enable Cachet output. |
|Script.UseDiscord  | Enable Discord output |
|Discord.DiscordWebhookURL | Webhook URL for Discord logging |
|Discord.DiscordEmbedURL   | URL for Embed Title |
|Discord.DiscordEmbedTitleOK  | Title of OK status Message   |
|Discord.DiscordEmbedOkColor  | Message highlight color      |
|Discord.DiscordEmbedThumbnailOkURL   | Direct image URL for message thumbnail (png recommended) |
|Discord.DiscordEmbedTitleFail   |  Title of FAIL status Message  |
|Discord.DiscordEmbedFailColor   | Message highlight color   |
|Discord.DiscordEmbedThumbnailFailURL  | Direct image URL for message thumbnail (png recommended)    |
|Discord.DiscordEmbedTitleUpdate   |  Title of UPDATE status Message  |
|Discord.DiscordEmbedUpdateColor   |  Message highlight color   |
|Discord.DiscordEmbedThumbnailUpdateURL   |  Direct image URL for message thumbnail (png recommended)   |
|Plex.PlexLocalURL    |   Local URL for Plex (MANDATORY)  |
|Plex.PlexRemoteURL   | Remote URL for Plex (Optional) |
|Cachet.CachetToken | Cachet API Token |
|Cachet.CachetPlexURL | API URL for Plex Component |
|Cachet.PlexWDUrl | API URL for PlexWatchDog Component (Optional) |
|Cachet.PlexComponentID | API ID for Plex component |
|Cachet.PlexWatchDogCompID | API ID for PlexWatchDog component. Only needed if using PlexWDUrl! |
|EventMessages.StatusOkayFile | Specifies text file for Okay message status. (Discord Logging) |
|EventMessages.StatusFailFile | Specifies text file for Fail message status. (Discord Logging) |
|Event.Messages.StatusUpdateFile | Specifies text file for Update message status. (Discord Logging) |

4. Start the `pmsdogservice.ps1` script.
5. ??
6. Profit.

# Discord Status Messages
![](\img\readme-discordmsgs.jpg)

Discord status messages are sent to a specified channel via a webhook. You can create this webhook in your channel settings. Messages are editable except for the timestamp. Message types are defined in the `config.json` in the `"Discord"` section. Message descriptions are inside the 3 text files in the root directory.
- `Okay.txt`
- `Fail.txt`
- `Update.txt`

![](\img\readme-dismsgbreakdown.jpg)
With Thumbnail:

![](\img\readme-discordmsgwithicon.jpg)

# Dev Env
- Install / Upgrade to PS 7.0.3+
- If using VS Code, install the Powershell IDE extension 2020.6.0. (ID: ms-vscode.powershell)