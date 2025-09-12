function Get-MipFile {
	<#
	.SYNOPSIS
		Returns the comprehensive label & protection status of a file.
		
	.DESCRIPTION
		Returns the comprehensive label & protection status of a file.

		Must be connected first using "Connect-InformationProtection".
	
	.PARAMETER Path
		Path to the file to scan.
	
	.EXAMPLE
		PS C:\> Get-MipFile -Path .\*

		Returns the label & protection status of every file in the current folder.

	.EXAMPLE
		PS C:\> Get-ChildItem -Recurse -File | Get-MipFile

		Returns the label & protection status of every file in the current folder and all subfolders.
	#>
	[OutputType([InformationProtection.File])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[PSFFile]
		$Path
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet
	}
	process {
		foreach ($filePath in $Path) {
			[InformationProtection.File]::new($filePath)
		}
	}
}