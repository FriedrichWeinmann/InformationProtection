function Import-MipSession {
	<#
	.SYNOPSIS
		Uses a provided MipSession as the default session used by the module.
	
	.DESCRIPTION
		Uses a provided MipSession as the default session used by the module.
		Use this command to pass an established session object to a background runspace, or to conveniently switch between separate connections.
	
	.PARAMETER Session
		MIP Session to use for the operation.
		Use "New-MipSession" to create a standalone session object.
	
	.EXAMPLE
		PS C:\> Import-MipSession -Session $session

		Uses the provided MipSession as the default session used by the module.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[InformationProtection.MipSession]
		$Session
	)
	process {
		$script:_session = $Session
	}
}