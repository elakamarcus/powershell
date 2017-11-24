function get-BIOS {

    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeLine=$true,ValueFromPipeLineByPropertyName=$true,Position=0)]
            [ValidateNotNullorEmpty()]
            [String[]]$ComputerName
    )
    $bios = (Get-WmiObject win32_bios -ComputerName $ComputerName).SMBIOSBIOSVersion
    $model = (Get-WmiObject win32_computersystem -ComputerName $ComputerName).model
    Write-Host $ComputerName 
    write-host Model: $model BIOS: $bios
}

function get-OnOff {
    #$ErrorActionPreference="SilentlyContinue"
      [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeLine=$true,ValueFromPipeLineByPropertyName=$true,Position=0)]
    [string]$ComputerName,
    [Parameter(Mandatory=$false,ValueFromPipeLine=$true,ValueFromPipeLineByPropertyName=$true,Position=0)]
    [string]$list,
    [int]$EventIDOn = 6005,
    [int]$EventIDoff = 6006
    )

    function GetBootTypeFromID ($EventID) {
        if($EventID -eq "6005") {
            echo "Power on"
        }
        else { return "Power off" }
    }
    function getSecLogs ($PCName) {
        Get-EventLog -LogName System -ComputerName $PCName | ?{ $_.EventID -eq 6006 -or $_.EventID -eq 6005} 
    }
    if(!$list) { $list = [int]5 }
    try { getSecLogs $ComputerName | select -First $list @{N="Type";E={GetBootTypeFromID $_.EventID}}, @{N="Time";E={$_.TimeGenerated}} | ft -AutoSize }
    catch [System.Exception] {
    }
}

function get-USBs {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false, ValueFromPipeLine=$true, ValueFromPipeLineByPropertyName=$true,Position=0)]
    [string]$ComputerName
    )

    if ($ComputerName) {
        try { Invoke-Command -ComputerName $ComputerName { Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\* | select FriendlyName } }
        catch {}
    }
    elseif ($env:COMPUTERNAME) {
        try { Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\*\* | select FriendlyName }
        catch {}
    }
}
