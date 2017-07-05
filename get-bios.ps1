
function get-BIOS {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')] 
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   ValueFromPipeLineByPropertyName=$true,
                   Position=0)]
            [ValidateNotNullorEmpty()]
            [String[]]$ComputerName
    )
    $bios = (Get-WmiObject win32_bios -ComputerName $ComputerName).SMBIOSBIOSVersion
    $model = (Get-WmiObject win32_computersystem -ComputerName $ComputerName).model
    Write-Host $ComputerName 
    write-host Model: $model 
    write-host BIOS: $bios
}
