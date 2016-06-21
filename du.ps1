function du($dir=".") { 
  get-childitem $dir | 
    % { $f = $_ ; 
        get-childitem -r $_.FullName | 
           measure-object -property length -sum | 
             select @{N="Name";E={$f}}, @{N="Sum";e={ '{0:N2} MB' -f ([int]$_.Sum/1MB)}}}
} 

# code copied and modified from http://stackoverflow.com/questions/868264/du-in-powershell
# very useful when trying to determine folder sizes in windows cli
