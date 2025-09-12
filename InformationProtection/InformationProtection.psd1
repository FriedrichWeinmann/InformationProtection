@{
	# Script module or binary module file associated with this manifest
	RootModule = 'InformationProtection.psm1'
	
	# Version number of this module.
	ModuleVersion = '0.9.2'
	
	# ID used to uniquely identify this module
	GUID = '8513ebee-5a70-4df1-95ee-f7232fc76702'
	
	# Author of this module
	Author = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName = 'Microsoft'
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2025 Friedrich Weinmann'
	
	# Description of the functionality provided by this module
	Description = 'Wraps the Microsoft Information Protection SDK'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.13.406' }
		@{ ModuleName='EntraAuth'; ModuleVersion='1.8.50' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @(
		'bin\Microsoft.InformationProtection.dll'
		'bin\InformationProtection.dll'
	)
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @('xml\InformationProtection.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\InformationProtection.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Connect-InformationProtection'
		'Get-MipFile'
		'Get-MipLabel'
		'Set-MipLabel'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = @()
	
	# Variables to export from this module
	VariablesToExport = @()
	
	# Aliases to export from this module
	AliasesToExport = @()
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('mip','label')
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/FriedrichWeinmann/InformationProtection/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/FriedrichWeinmann/InformationProtection'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/FriedrichWeinmann/InformationProtection/blob/master/InformationProtection/changelog.md'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}