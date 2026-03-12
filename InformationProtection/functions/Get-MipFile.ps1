function Get-MipFile {
	<#
	.SYNOPSIS
		Returns the comprehensive label & protection status of a file.
		
	.DESCRIPTION
		Returns the comprehensive label & protection status of a file.

		Must be connected first using "Connect-InformationProtection".
	
	.PARAMETER Path
		Path to the file to scan.

	.PARAMETER Session
		MIP Session to use for the operation.
		Overrides the use of the default session and would be used in situations when relabeling files from one tenant to another.
		Use "New-MipSession" to create a standalone session object.
	
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
		$Path,

		[InformationProtection.MipSession]
		$Session
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet -Session $Session
		$sessionToUse = $script:_session
		if ($Session.Context) { $sessionToUse = $Session}
	}
	process {
		foreach ($filePath in $Path) {
			[InformationProtection.File]::new($filePath, $sessionToUse)
		}
	}
}