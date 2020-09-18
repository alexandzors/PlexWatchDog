# PlexWatchDog
A PowerShell script to monitor your Plex Media Server.

# WARNING
This script is still a W.I.P. Use at your own risk!

# What do I do?

PlexWatchDog monitors your Plex Media Server via the local web interface. If the web client returns a code other than Status 200 (aka Okay!) the script will automatically:
1. Send a notification to a configured endpoint (Discord, or Cachet currently)
2. Automatically kill all Plex processes
3. Restart the Plex Media Server.exe.

*This script assumes that Plex is installed into the default directory. If enough people see the need I could make the location configurable via the config.json*

# To-Do
- Create a xml for Task Scheduler for automatic script running on machine restarts.
- Move check for update service functionality into Get-PlexStatus function. So that `pmsdogservice.ps1` is only reading the config file, sending notifications, and restarting processes/services.
- Figure out a better way to make this script headless and not rely on a Do-Until loop. ;)
- Upgrade `pmsdogservice.ps1` to monitor plex when installed as a system service.
- Upgrade Write-Log function to be usable for constant verbose logging.
- Make the script a service??

# Pre-Notes
This script was built in a PowerShell 7.0.3 environment. So it is recommended to upgrade to PS 7.0.3.

![PowerShell Version](/img/readme-psversion.jpg)

This repo also contains the required function files found in `/Utils` so no third party functions are required to be installed.

You will need to update your systems Execution Policies to run this script. Plenty of docs on how to do that.

# How to Use
1. Download the Repo as a ZIP
2. Extract into desired location
3. Edit the `config.json` file to match your environment preferences


|Config   |Value  | Working? |
|---------|---------|---------|
|Script.Timeout     | Value in Seconds (default 60) | **Yes** |
|Script.UseCachet   | Enable Cachet output. |  **Yes** |
|Script.UseDiscord  | Enable Discord output |  **Yes** |
|Discord.DiscordWebhookURL | Webhook URL for Discord logging |  **Yes** |
|Discord.DiscordEmbedURL   | URL for Embed Title |  **Yes** |
|Discord.DiscordEmbedTitleOK  | Title of OK status Message   |  **Yes** |
|Discord.DiscordEmbedOkColor  | Message highlight color      |  **Yes** |
|Discord.DiscordEmbedThumbnailOkURL   | Direct image URL for message thumbnail (png recommended) |  **Yes** |
|Discord.DiscordEmbedTitleFail   |  Title of FAIL status Message  |  **Yes** |
|Discord.DiscordEmbedFailColor   | Message highlight color   |  **Yes** |
|Discord.DiscordEmbedThumbnailFailURL  | Direct image URL for message thumbnail (png recommended)    |  **Yes** |
|Discord.DiscordEmbedTitleUpdate   |  Title of UPDATE status Message  | **No** |
|Discord.DiscordEmbedUpdateColor   |  Message highlight color   | **No** |
|Discord.DiscordEmbedThumbnailUpdateURL   |  Direct image URL for message thumbnail (png recommended)   | **No** |
|Plex.PlexLocalURL    |   Local URL for Plex (MANDATORY)  | **Yes** |
|Plex.PlexRemoteURL   | Remote URL for Plex (Optional) | **No** |
|Cachet.CachetToken | Cachet API Token |  **Yes** |
|Cachet.CachetPlexURL | API URL for Plex Component |  **Yes** |
|Cachet.PlexWDUrl | API URL for PlexWatchDog Component (Optional) |  **Yes** |
|Cachet.PlexComponentID | API ID for Plex component |  **Yes** |
|Cachet.PlexWatchDogCompID | API ID for PlexWatchDog component. Only needed if using PlexWDUrl! |  **Yes** |
|EventMessages.StatusOkayFile | Specifies text file for Okay message status. (Discord Logging) |  **Yes** |
|EventMessages.StatusFailFile | Specifies text file for Fail message status. (Discord Logging) |  **Yes** |
|Event.Messages.StatusUpdateFile | Specifies text file for Update message status. (Discord Logging) | **No** |

4. Start the `pmsdogservice.ps1` script.
5. ??
6. Profit.

# Discord Status Messages
![Discord Messages](/img/readme-discordmsgs.jpg)

Discord status messages are sent to a specified channel via a webhook. You can create this webhook in your channel settings. Messages are editable except for the timestamp. Message types are defined in the `config.json` in the `"Discord"` section. Message descriptions are inside the 3 text files in the root directory.
- `Okay.txt`
- `Fail.txt`
- `Update.txt`

![Message Breakdown for Discord Messages](/img/readme-dismsgbreakdown.jpg)
With Thumbnail:

![Discord Message with Thumbnail](/img/readme-discordmsgwithicon.jpg)

# Dev Env
- Install / Upgrade to PS 7.0.3+
- If using VS Code, install the Powershell IDE extension 2020.6.0. (ID: ms-vscode.powershell)
