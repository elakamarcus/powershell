<#
  A man who has committed a mistake and does not correct it, is committing another mistake.
#>

$bundle = @()
$b = 0
$global:newPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString)

function setPwdChange {
  set-aduser -identity $args[0] -ChangePasswordAtLogon $true
  write-host "[+] " $args[0] "must change password on next logon."
}

function NewPassword {
    Set-ADAccountPassword -Identity $args[0] -NewPassword $global:newPassword -Reset
    write-host "[+] "$args[0]"'s password has been changed."
    setPwdChange $args[0]
}

if (!$args[0] -or $args[1]) {
    Write-Host "[!] Execute with input file as only parameter."  
}
else {
    $bundle = get-content $args[0]
  foreach($user in $bundle) {
    NewPassword $user
    $b += 1;
  }
}
Write-Host $b "useraccounts updated."