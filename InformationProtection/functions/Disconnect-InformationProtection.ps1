function Disconnect-InformationProtection {
	<#
	.SYNOPSIS
		Disconnects from MIP.
	
	.DESCRIPTION
		Disconnects from MIP.
	
	.PARAMETER Session
		The MIP Session to disconnect from.
	
	.EXAMPLE
		PS C:\> Disconnect-InformationProtection

		Disconnects the current default-session, if present.

	.EXAMPLE
		PS C:\> Disconnect-InformationProtection -Session $session

		Disconnects the provided MIP session.
	#>
	[CmdletBinding()]
	param (
		[InformationProtection.MipSession]
		$Session
	)
	process {
		if ($Session) { $session.Disconnect() }
		elseif ($script:_Session) {
			$script:_Session.Disconnect()
			$script:_Session = $null
		}
	}
}