#Suppress error messages, because a lot of searches will be made in the wrong domain....
$ErrorActionPreference="SilentlyContinue"
[int]$EventIDOn = 6005
[int]$EventIDoff = 6006
[int]$Global:list = 5

function GetBootTypeFromID ($EventID) {
  if($EventID -eq "6005") {
    echo "Power on"
  }
  else {
    return "Power off"
  }
}
<# Use this a CMDLET:
function Get-SystemPoweredOnOff {
  [CmdletBinding()]
  Param(
    [string]$ComputerName,
    [int]$EventIDOn = 6005,
    [int]$EventIDoff = 6006
  )
  Get-EventLog -LogName System -ComputerName $ComputerName | ?{where $_.EventID -eq $EventIDOn -or $_.EventID -eq $EventIDoff} | select -First 15
}
#>
function getSecLogs ($PCName) {
  Get-EventLog -LogName System -ComputerName $PCName | ?{ $_.EventID -eq 6006 -or $_.EventID -eq 6005} 
}
if (!$args[0] -or $args[2]) {
  Write-Host "[!] Too many or too few parameters."
  Write-Host "[!] Execute with machine name as parameter."
  Write-Host "[+] Optional parameter how many entries as a single int, e.g. 10. Default is 5."
}
if($args[1]) {
  $Global:list = $args[1]
}
try {
  getSecLogs $args[0] | select -First $Global:list @{N="Type";E={GetBootTypeFromID $_.EventID}}, @{N="Time";E={$_.TimeGenerated}}    
}
catch [System.Exception] {
    
}
