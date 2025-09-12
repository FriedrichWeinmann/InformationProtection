function Assert-MIPConnection {
	<#
	.SYNOPSIS
		Ensures the session is correctly connected already.
	
	.DESCRIPTION
		Ensures the session is correctly connected already.
		Throws a bloody terminating exception if not so.
		Use Connect-InformationProtection to connect first, which requires corresponding EntraAuth sessions.
	
	.PARAMETER Cmdlet
		The $PSCmdlet variable of the caller.
		Used to create the error in the context of the caller.
	
	.EXAMPLE
		PS C:\> Assert-MIPConnection -Cmdlet $PSCmdlet

		Ensures the session is correctly connected already.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$Cmdlet
	)
	process {
		if ([InformationProtection.MipHost]::Context) { return }

		$errorRecord = [System.Management.Automation.ErrorRecord]::new(
			[System.InvalidOperationException]::new("Not yet connected! Use Connect-InformationProtection to connect first!"),
			"NotConnectedOmae!",
			[System.Management.Automation.ErrorCategory]::ConnectionError,
			$null
		)
		$Cmdlet.ThrowTerminatingError($errorRecord)
	}
}