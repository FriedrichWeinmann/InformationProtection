function Get-MipLabel {
	<#
	.SYNOPSIS
		List available labels or labels assigned to a file.
		
	.DESCRIPTION
		List available labels or labels assigned to a file.

		Must be connected first using "Connect-InformationProtection".
	
	.PARAMETER Path
		Path to the file(s) to retrieve labels from.
		Note: Consider using Get-MipFile instead, for a more comprehensive few at the state of a file.
	
	.PARAMETER Filter
		Name to filter the scopes by, when listing the available scopes.

	.PARAMETER Session
		MIP Session to use for the operation.
		Overrides the use of the default session and would be used in situations when relabeling files from one tenant to another.
		Use "New-MipSession" to create a standalone session object.
	
	.EXAMPLE
		PS C:\> Get-MipLabel

		List all available labels

	.EXAMPLE
		PS C:\> Get-MipLabel -Path .\accounting-summary.xlsx

		Returns the label applied to "accounting-summary.xlsx"
	#>
	[CmdletBinding(DefaultParameterSetName = 'List')]
	param (
		[Parameter(ValueFromPipeline = $true, ParameterSetName = 'File')]
		[PsfFile]
		$Path,
		
		[Parameter(ParameterSetName = 'List')]
		[string]
		$Filter = '*',

		[InformationProtection.MipSession]
		$Session
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet -Session $Session
		$sessionToUse = $script:_session
		if ($Session.Context) { $sessionToUse = $Session }
	}
	process {
		if ($PSCmdlet.ParameterSetName -eq 'List') {
			foreach ($label in $sessionToUse.FileEngine.SensitivityLabels) {
				if ($label.ID -eq $Filter -or $label.Name -like $Filter -or $label.FQLN -like $Filter) { $label }
				foreach ($childLabel in $label.Children) {
					if ($childLabel.ID -eq $Filter -or $childLabel.Name -like $Filter -or $childLabel.FQLN -like $Filter) { $childLabel }
				}
			}
			return
		}

		foreach ($file in $Path) {
			([InformationProtection.File]::new($file, $sessionToUse)).GetLabel()
		}
	}
}