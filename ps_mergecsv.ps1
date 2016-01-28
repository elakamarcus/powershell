<#
 In Waking Tiger, Use A Long Stick
#>

#Global variables
$path = "pathToFolderwithCSV-files"
$files = (Get-ChildItem -Path $path -Filter "*.csv").name

function formatOut {
    $args[0]+","+$args[1]
}

foreach ( $file in $files ) {
    Get-Content $path\$file | % { formatOut $file.split(".")[0] $_ }
}
