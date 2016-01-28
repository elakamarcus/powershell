<# "A flipped coin doesn't always land heads or tails. Sometimes it may not land at all." #>
$domains = ("domain1", "domain2", "domain3")
"Domain;ComputerName;Description;Canonical;Enabled"

#Matching the output, print to screen, what is then piped to a textfile. This can be done within the for-loop.
function FormatOut {
    #Unfortunately i have to format the output like this, because some names may contain "," which will not work well for CSV.
    $args[1].Split(".")[0] + ";" + $args[0].name + ";" + $args[0].Description + ";" + $args[0].CanonicalName + ";" + $args[0].enabled
}
#This does what it says, for each domain in domains-array, get every computer which is a member of organisational unit "<SPECIFIED>".
foreach ( $domain in $domains ) {
    $machines = @()
    #Replace <SPECIFIED> with what membership you are looking for.
    $machines = get-adcomputer -Filter 'ObjectClass -eq "Computer"' -Properties Description, CanonicalName -server $domain |
    ? {$_.DistinguishedName -like "*OU=<SPECIFIED>,*"}
    foreach ( $machine in $machines ) {
        FormatOut $machine $domain
    }
}
