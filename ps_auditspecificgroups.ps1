#Suppress error messages, because a lot of searches will be made in the wrong domain....
$ErrorActionPreference="SilentlyContinue"
#if you are in a multidomain-environment:, if not, just add your only domain.
$domains = ("domain1", "domain2", "domain3")
#define which groups to review, this could be configured to be read from a file, passed as parameter args[0]
$groups = ("name", "of", "privilege", "security", "groups")

#define necessary arrays
$bulk = @()
$sams = @()
#Unnice solution to headers
"Domain;Group;UserID;UserName;Description;title"
#because i love for-loops
foreach($group in $groups) {
    foreach($domain in $domains) {
        #add user ID's to array
        $sams = (Get-ADGroupMember -Identity $group -Server $domain -Recursive).samaccountname
        foreach( $id in $sams ) {
            #don't forget to add $domain here, otherwise will search the current/local domain. Properties * just because who knows what we will look up in the future.
            $user = Get-ADUser -Identity $id -Server $domain -properties *
            #Very ugly solution instead of throw exception
            #if-statement should not be necessary when user is cleared.
            if ($user.name) {
                #Print so we can append to file
                $domain.split(".")[0] + ";" + $group + ";" +  $user.samaccountname + ";" + $user.name +";" + $user.description + ";"
                #Clear variable
                $user = "" 
            }
            else {
                # or else what...? -Exactly!
            }
        }
        #Clear sams for next group/domain
        $sams = ""
    }
}
