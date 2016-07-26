
#In case it's not possible or feasible to export to csv etc. use this function.
#column headers, to work with the function "formatOut"
"Mailbox Owner"+";"+"Permission"+";"+"User"
function formatOut {
    $args[0]+";"+$args[1]+";"+$args[2]
}

$creds = get-credential
(Replace RRR with your region)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri  http://exchangesrv/PowerShell/ -Authentication Kerberos -Credential $creds
Import-PSSession $Session
#Get mailboxes that has an activesync connected device
$Mailboxes = Get-CASMailbox -Filter {HasActivesyncDevicePartnership -eq $true}
#Get the devices
$Devices = $Mailboxes | %{Get-ActiveSyncDeviceStatistics -Mailbox $_.Identity}
#Filter what devices, e.g. Surface Pro/Book
$SurfaceDevices = $Devices | ?{ $_.DeviceModel -like "*Surface* " } | select -Property @{N='Owner';E={$_.Identity.split( "/")[4]}}, @{N='Office';E={$_.Identity.split( "/")[2]}}, DeviceModel

#
# Mailbox permissions for specific account:
# Get-MailboxPermission -Identity SamAccoutName | ? {$_.User -match "SamAccoutName-regex"} | %{get-aduser -identity ($_.user.split("\")[1]) | select name}
#

# Show what accounts are granted permission on mailbox Get-MailboxPermission -Identity <USERID> | select user
#Get mailbox permissions and filter out system account. this will take a while.
$mailboxPermissions = Get-Mailbox -ResultSize unlimited| Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false}
foreach($item in $mailboxPermissions) { 
    #This section need review based on the setup. Basically you want a user name or samaccountname.
    $cut = ""
    $cut = ($item.Identity.ToCharArray() | Where-Object {$_ -eq "/"}| Measure-Object).count
    $owner = $item.Identity.Split("/")[$cut]

    #Same as bullet above
    if($item.User -match "regex for username") {
        $user=(get-aduser -i $item.User.Split("\")[1]).name
    }
    else{
        if($item.User -match "alternative form") {
            $user = $item.User.Split("\")[1]
        }
        else{
        $user = $item.user
        }
    }
    formatOut $owner $item.AccessRights $user
    #cleanup
    $user=""
    $owner=""
}