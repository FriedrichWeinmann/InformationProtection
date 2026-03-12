# Loads the correct DLL version for the OS
$processor = Get-CimInstance -ClassName Win32_Processor
$lock = Get-PSFRunspaceLock -Name 'MIP.Library.Import'
if ($processor.Architecture -in 5, 12) {
	$lock.Open()
	try {
		Add-Type -Path "$($script:ModuleRoot)\bin\arm64\Microsoft.InformationProtection.dll" -ErrorAction Stop
		Add-Type -Path "$($script:ModuleRoot)\bin\InformationProtection.dll" -ErrorAction Stop
	}
	finally { $lock.Close() }
}
else {
	$lock.Open()
	try {
		Add-Type -Path "$($script:ModuleRoot)\bin\Microsoft.InformationProtection.dll" -ErrorAction Stop
		Add-Type -Path "$($script:ModuleRoot)\bin\InformationProtection.dll" -ErrorAction Stop
	}
	finally { $lock.Close() }
}