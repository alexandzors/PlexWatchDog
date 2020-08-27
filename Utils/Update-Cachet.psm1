# Created by github.com/alexandzors
# Created: 2020/08/14 02:09:26
# Last modified: 2020/08/27 01:33:06
Import-Module ".\Utils\Write-Log.psm1"
<#
.SYNOPSIS
    Update components on Cachet.
.DESCRIPTION
    This function makes it possible to update Cachet status page using the API.
.EXAMPLE
    PS C:\> Update-Cachet -ok -token 'API TOKEN' -id 1 -compURL 'https://status.urdomain.net/api/v1/component/1'
.EXAMPLE
    PS C:\> Update-Cachet -fail -token 'API TOKEN' -id 1 -compURL 'https://status.urdomain.net/api/v1/component/1'    
.INPUTS
    -ok = OK status switch.
    -fail = Fail status switch.
    -token = API Token for Cachet API.
    -id = ID of your service component.
    -compURL = API URL of your component.
#>
function Update-Cachet {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $ok,
        [Parameter()]
        [switch]
        $fail,
        [Parameter(Mandatory)]
        [string]
        $Token,
        [Parameter(Mandatory)]
        [int]
        $id,
        [Parameter(Mandatory)]
        [string]
        $compURL
    )
    try {
        if ($ok) {
            Write-Verbose "Update-Cachet: Sending OK status to Cachet API for Component ID: $id"
            $bodyok = '{"status":"1","id":' + $id + '}'
            Invoke-WebRequest -Method PUT -Headers @{'X-Cachet-Token' = $Token} -ContentType 'application/json' -Uri $compURL -Body $bodyok
            Write-Verbose "Update-Cachet: Status sent successfully for Component ID: $id!"
        } elseif ($fail) {
            Write-Verbose "Update-Cachet: Sending FAIL status to Cachet API for Component ID: $id."
            $bodyfail = '{"status":"4","id":' + $id + '}'
            Invoke-WebRequest -Method PUT -Headers @{'X-Cachet-Token' = $Token} -ContentType 'application/json' -Uri $compURL -Body $bodyfail
            Write-Verbose "Update-Cachet: Status sent successfully for Component ID: $id!"
        }
    } catch {
        Write-Verbose "Update-Cachet ERROR: "$_.Exception
        Write-Log -LogOutput ("Update-Cachet ERROR: " + $_.Exception.Message)     
    }
}