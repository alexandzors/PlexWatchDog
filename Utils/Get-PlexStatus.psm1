# Created by github.com/alexandzors
# Created: 2020/08/15 03:19:15
# Last modified: 2020/09/16 13:46:35
Import-Module ".\Utils\Write-Log.psm1"
<#
.SYNOPSIS
    Get the status of Plex Media Server.
.DESCRIPTION
    This function checks the status code of the Plex Media Server via the local web interface.
.EXAMPLE
    PS C:\> $code = Get-PlexStatus -localurl "https://127.0.0.1:32400/web/index.html"
.EXAMPLE
    PS C:\> Get-PlexStatus -localurl "https://127.0.0.1:32400/web/index.html"
    200
.INPUTS
    -localurl = Local url used to access the Plex interface.
.OUTPUTS
    Script returns a status code. $statuscode.
.NOTES
    Setting the function to a variable allows you to get the returned status code and check it. 
    If Plex is running a status code of 200 is returned. Otherwise a 0 is returned on function error.   
#>
function Get-PlexStatus {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $localurl
    )
    $statuscode =
    Write-Verbose "Get-PlexStatus: Local URL $localurl"
    try {
        if (-not $localurl -eq "") {
            try {
                Write-Verbose "Get-PlexStatus: Checking Plex Local URL Status: $localurl"
                $HTTP_LOCAL_Request = [System.Net.WebRequest]::Create($localurl)
                $HTTP_LOCAL_Request.Timeout = 15000
                $HTTP_LOCAL_Response = $HTTP_LOCAL_Request.GetResponse()
                $statuscode = [int]$HTTP_LOCAL_Response.StatusCode
                Write-Verbose "Get-PlexStatus: Returning status code: $statuscode"
                Return $statuscode
            } catch {
                Write-Verbose $_.Exception.Message
                Return 0
            }
        }
        else {
            Write-Verbose "-localurl is not set! Please set a local url when calling Get-PlexStatus"
            Write-Log -LogOutput ("-localurl is not set! Please set a local url when calling Get-PlexStatus")
        }
    }
    catch {
        Write-Verbose "Get-PlexStatus: "$_.Exception.Message
        Write-Log -LogOutput ("Get-PlexStatus ERROR: " + $_.Exception.Message)     
    }
}