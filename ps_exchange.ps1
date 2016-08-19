
#In case it's not possible or feasible to export to csv etc. use this function.
#column headers, to work with the function "formatOut"
"Mailbox Owner"+";"+"Permission"+";"+"User"
function formatOut {
    $args[0]+";"+$args[1]+";"+$args[2]
}

$creds = get-credential

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
# Get the folders and their size for specific user:
# get-aduser -filter {name -like "*namehere*"} | %{Get-MailboxFolderStatistics -Identity $_.DistinguishedName } | select @{N="Folder";E={$_.Identity.replace("remove-eventual-ad-strings", "")}},ItemsInFolder,FolderSize | ft –AutoSize
#
# Get the size of the mailbox and number of items 
# PS C:\WINDOWS\system32> get-aduser -filter {name -like "*namehere*"} | %{Get-MailboxStatistics -Identity $_.DistinguishedName } | select itemcount, totalitemsize | ft -AutoSize
# 
# Show what accounts are granted permission on mailbox Get-MailboxPermission -Identity <USERID> | select user
#Get mailbox permissions and filter out system account. this will take a while.
$mailboxPermissions = Get-Mailbox -ResultSize unlimited| Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false}
foreach($item in $mailboxPermissions) { 
    #This section need review based on the setup. Basically you want a user name or samaccountname.
    #below will take the last column of a string of columns separated by "/"
    $owner = $item.Identity.Split("/")[$(($item.Identity.ToCharArray() | Where-Object {$_ -eq "/"}| Measure-Object).count)]

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