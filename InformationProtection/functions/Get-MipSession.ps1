function Get-MipSession {
	<#
	.SYNOPSIS
		Returns the currently established MIP session.
	
	.DESCRIPTION
		Returns the currently established MIP session.
		Returns nothing unless "Connect-InformationProtection" has been run first.
	
	.EXAMPLE
		PS C:\> Get-MipSession

		Returns the currently established MIP session.
	#>
	[OutputType([InformationProtection.MipSession])]
	[CmdletBinding()]
	param ()
	process {
		if ($script:_session) {
			$script:_session
		}
	}
}