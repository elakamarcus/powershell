# This script was found on http://www.powershellpro.com/how-do-i-know-if-im-missing-ms-patches/640/ and then modified after my needs
# This script requires Excel and MBSA installed on your computer.

# Unfixed issues: execution error from MBSAcli, works fine outside powershell, but something breaks when running mbsacli in PS

#Excel-stuff so the file can be properly saved
Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault

#Link and read a list of hosts/target machines.
$contentfile = Read-host "Link to file with hosts"
$Computers = Get-content $contentfile

#Self-explanatory
$strDomain = Read-Host “Enter the Domain Name”
$execUser = Read-Host "Execute as"
$userPWD = Read-Host "Password"

#Define useful paths
$Temp = 'C:\TEMP\'
$Path = 'C:\Program Files\Microsoft Baseline Security Analyzer 2'

#Create new com object Excel
$Excel = New-Object -Com Excel.Application
$Excel.visible = $True
$werkbook = $Excel.Workbooks.Add()

#counter to add appropriate number of sheets.
$count = 1

Set-Location $Path

foreach ($Computer in $Computers) {
  #create a sheet per computer listed
	$Sheet1 = $werkbook.Worksheets.Item($count)
	
	#name the sheet
	$Sheet1.Name = "$Computer"

	#Create Heading for patch Sheet
	$Sheet1.Cells.Item(1,1).FormulaLocal = 'Computer_Name'
	$Sheet1.Cells.Item(1,2) = 'Patch_Information'
	$intRow = 2
	$WorkBook = $sheet1.UsedRange
	$WorkBook.Interior.ColorIndex = 20
	$WorkBook.Font.ColorIndex = 11
	$WorkBook.Font.Bold = $True

	#do it
	$cmd = "cmd.exe /c mbsacli.exe /u $strDomain\$execUser /p $userPWD /Target $Computer /n OS+SQL+IIS+Password >$TempMBSA$Computer.txt"
	Invoke-Expression $cmd

	$logResults = (Get-Content "$TempMBSA$Computer.txt") -match 'Missing'
	foreach($Item in $logResults){
		$Sheet1.Cells.Item($intRow, 1) = $Computer
		$Sheet1.Cells.Item($intRow, 2) = $Item
		$intRow = $intRow + 1
	}
	$count += 1
}

#Auto Fit all sheets in the Workbook
$WorkBook.EntireColumn.AutoFit()
$werkbook.ActiveWorkbook.SaveAs("$Temp$strDomain_MS_Missing_Patches.xls", $xlFixedFormat)
$werkbook.Close()
$werkbook.Quit()

#delete Temp File
Remove-Item “$TempMBSA$Computer.txt”
