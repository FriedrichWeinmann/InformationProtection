function Get-MipFile {
	<#
	.SYNOPSIS
		Returns the comprehensive label & protection status of a file.
		
	.DESCRIPTION
		Returns the comprehensive label & protection status of a file.

		Must be connected first using "Connect-InformationProtection".
	
	.PARAMETER Path
		Path to the file(s) to scan.

	.PARAMETER LiteralPath
		Path to the file(s) to scan.
		Does not interpret wildcards.

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
		[Parameter(ValueFromPipeline = $true)]
		[PSFFile]
		$Path,

		[PSFLiteralPath]
		$LiteralPath,

		[InformationProtection.MipSession]
		$Session
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet -Session $Session
		$sessionToUse = $script:_session
		if ($Session.Context) { $sessionToUse = $Session}
	}
	process {
		if (-not ($Path -or $LiteralPath)) {
			Stop-PSFFunction -String 'General.Error.NoPath' -Cmdlet $PSCmdlet -EnableException $true -Category InvalidArgument
		}
		$resolvedPaths = $Path + $LiteralPath | Select-Object -Unique
		foreach ($filePath in $resolvedPaths) {
			if (-not $filePath) { continue }
			try { [InformationProtection.File]::new($filePath, $sessionToUse, $true) }
			catch {
				# Better message if possible
				if ($_.Exception.GetBaseException() -is [Microsoft.InformationProtection.Exceptions.BadInputException]) {
					Write-Error -Message $_.Exception.GetBaseException().Message -TargetObject $filePath
				}
				else {
					Write-Error -Message $_ -TargetObject $filePath
				}
			}
		}
	}
}