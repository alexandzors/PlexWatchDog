# Created by github.com/alexandzors
# Created: 2020/08/15 03:19:15
# Last modified: 2020/09/15 01:32:40
Import-Module ".\Utils\Write-Log.psm1"
<#
.SYNOPSIS
    Get the status of Plex Media Server.
.DESCRIPTION
    This function checks the status code of the Plex Media Server via the web interface.
.EXAMPLE
    PS C:\> $code = Get-PlexStatus -localurl "https://127.0.0.1:32400/web/index.html"
.EXAMPLE
    PS C:\> Get-PlexStatus -localurl "https://127.0.0.1:32400/web/index.html"
    200
.INPUTS
    -localurl = Local url used to access the Plex interface.
    -remoteurl = Remote url used to access the plex interface.
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
        $localurl,
        [Parameter()]
        [string]
        $remoteurl
    )
    $statuscode = [int]
    Write-Verbose "Get-PlexStatus: Local URL $localurl"
    Write-Verbose "Get-PlexStatus: Remote URL $remoteurl"
    try {
        if ($remoteurl -eq "") {
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
        elseif ($localurl -eq "" -and -not $remoteurl -eq "") {
            try {
                Write-Verbose "Get-PlexStatus: Checking Plex Remote URL Status: $remoteurl"
                $HTTP_REMOTE_Request = [System.Net.WebRequest]::Create($remoteurl)
                $HTTP_REMOTE_Request.Timeout = 15000
                $HTTP_REMOTE_Response = $HTTP_LOCAL_Request.GetResponse()
                $statuscode = [int]$HTTP_REMOTE_Response.StatusCode
                Write-Verbose "Get-PlexStatus: Returning status code: $statuscode"
                Return $statuscode             
            } catch {
                Write-Verbose $_.Exception.Message
                Return 0
            }            
        }
        elseif (-not $remoteurl -eq "" -and $localurl -eq "") {
            try {
                Write-Verbose "Get-PlexStatus: Checking Plex Local URL Status: $localurl"
                $HTTP_LOCAL_Request = [System.Net.WebRequest]::Create($localurl)
                $HTTP_LOCAL_Request.Timeout = 15000
                $HTTP_LOCAL_Response = $HTTP_LOCAL_Request.GetResponse()
                $HTTP_LOCAL_Status = [int]$HTTP_LOCAL_Response.StatusCode
                if ($HTTP_LOCAL_Status -eq 200) {
                    Write-Verbose "Get-PlexStatus: Checking Plex Remote URL Status: $remoteurl"
                    $HTTP_REMOTE_Request = [System.Net.WebRequest]::Create($remoteurl)
                    $HTTP_REMOTE_Request.Timeout = 15000
                    $HTTP_REMOTE_Response = $HTTP_REMOTE_Request.GetResponse()
                    $statuscode = [int]$HTTP_REMOTE_Response.StatusCode
                    Write-Verbose "Get-PlexStatus: Returning status code: $statuscode"
                    Return $statuscode          
                }    
            } catch {
                Write-Verbose $_.Exception.Message
                Return 0
            }
     
        }
    }
    catch {
        Write-Verbose "Get-PlexStatus: "$_.Exception.Message
        Write-Log -LogOutput ("Get-PlexStatus ERROR: " + $_.Exception.Message)     
    }
}