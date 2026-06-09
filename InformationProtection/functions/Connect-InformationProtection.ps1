function Connect-InformationProtection {
	<#
	.SYNOPSIS
		Connect the Microsoft Information Protection SDK with Entra.
	
	.DESCRIPTION
		Connect the Microsoft Information Protection SDK with Entra.
		
		There are two ways to perform the authentication:

		+ Use previously established EntraAuth sessions
		+ Create new sessions

		1) Previously established sessions
		
		If you have already previously established a connection using "Connect-EntraService", you can reuse those.
		By default, the services you need a connection to are "AzureRightsManagement" and "MIPSyncService".
		This option gives you the free choice about authentication methods used, covering all the scenarios supported by EntraAuth.

		Example 1:

		Connect-EntraService -TenantID $tenantID -ClientID $clientID -Service AzureRightsManagement
		Connect-EntraService -TenantID $tenantID -ClientID $clientID -Service MIPSyncService -UseRefreshToken

		Note: This example assumes you previously already imported the InformationProtection module!

		Example 2:

		Connect-EntraService -TenantID $tenantID -ClientID $clientID -Service AzureRightsManagement, MIPSyncService -Certificate $cert

		2) Create new sessions

		You can establish new EntraAuth sessions as part of this command, by specifying the ClientID of the Entra Application to use:

		Connect-InformationProtection -ClientID $clientID

		This will always only be an interactive session, authenticating using the local default browser.

	.PARAMETER ServiceMap
		Optional hashtable to map service names to specific EntraAuth service instances.
		Used for advanced scenarios where you want to use something other than the default connections.
		Example: @{ AzureRightsManagement = 'MyARM' }
		This will switch all AzureRightsManagement API calls to use the service connection "MyARM".

	.PARAMETER ClientID
		The Application ID / Client ID of the Entra application used to authenticate.
		Specifying this will force the establishment of a new session through the browser.
		To reuse existing sessions, do not provide this parameter.

	.PARAMETER TenantID
		The tenant ID of the Entra application to use to authenticate.
		Defaults to: "organizations" (Which means the tenant, the selected account belongs to)

	.PARAMETER Certificate
		The certificate to use for authenticating to Entra for the AzureRightsManagement and MIPSyncService services.
		Requires specifying both ClientID and TenantID.
		When used, this will first authenticate as application to the provided application, before registering those sessions for the MIP SDK's use.

	.PARAMETER Email
		Email address to register on the session object.
		Used for metadata when labelling files.

	.PARAMETER PassThru
		Returns the MIP session as an object, on top of storing it as the module's default session.

	.PARAMETER LogLevel
		The level of details to include in the MIP-integrated logging.
		Logs can be found under "%localappdata%\PowerShell\InformationProtection\logs" or the non-windows equivalent.
		Defaults to: Error.
	
	.EXAMPLE
		PS C:\> Connect-InformationProtection

		Authenticate using already established EntraAuth sessions for the services "AzureRightsManagement" and "MIPSyncService".

	.EXAMPLE
		PS C:\> Connect-InformationProtection -ClientID $clientID

		Authenticate while creating new EntraAuth sessions for the services "AzureRightsManagement" and "MIPSyncService".
		This will only use the Authorization Code delegate authentication flow.
	#>
	[OutputType([InformationProtection.MipSession])]
	[CmdletBinding()]
	param (
		[hashtable]
		$ServiceMap = @{},

		[string]
		$ClientID,

		[string]
		$TenantID = 'organizations',

		[System.Security.Cryptography.X509Certificates.X509Certificate2]
		$Certificate,

		[string]
		$Email,

		[switch]
		$PassThru,

		[Microsoft.InformationProtection.LogLevel]
		$LogLevel = 'Error'
	)
	begin {
		$services = $script:_serviceSelector.GetServiceMap($ServiceMap)

		if ($ClientID) {
			if (-not $Certificate) {
				Connect-EntraService -TenantID $TenantID -ClientID $ClientID -Service $services.AzureRightsManagement
				Connect-EntraService -TenantID $TenantID -ClientID $ClientID -Service $services.MIPSyncService -UseRefreshToken
			}
			else {
				if (-not ($TenantID -as [guid])) {
					Stop-PSFFunction -String 'Connect-InformationProtection.Error.NoTenantId' -Cmdlet $PSCmdlet -EnableException $true -Category InvalidArgument
				}
				Connect-EntraService -TenantID $TenantID -ClientID $ClientID -Service $services.AzureRightsManagement, $services.MIPSyncService -Certificate $Certificate
			}
		}

		Assert-EntraConnection -Cmdlet $PSCmdlet -Service $services.AzureRightsManagement
		Assert-EntraConnection -Cmdlet $PSCmdlet -Service $services.MIPSyncService
	}
	process {
		$logPath = Join-Path -Path (Get-PSFPath -Name LocalAppData) -ChildPath "PowerShell\InformationProtection\logs\$([guid]::NewGuid())"
		$session = [InformationProtection.MipSession]::new()
		if ($Email) { $session.Email = $Email }
		try {
			$session.Authenticate(
				(Get-EntraToken -Service $services.AzureRightsManagement),
				(Get-EntraToken -Service $services.MIPSyncService),
				$logPath,
				$LogLevel
			)
		}
		catch {
			if ($_ -match 'LoadLibrary failed with error code 126') {
				Write-PSFMessage -Level Warning -String 'Connect-InformationProtection.Error.Code126'
			}
			Stop-PSFFunction -String 'Connect-InformationProtection.Error.Authenticate' -ErrorRecord $_ -Cmdlet $PSCmdlet -EnableException $true
		}
		if ($script:_session) {
			$script:_session.Disconnect()
		}
		$script:_session = $session

		if ($PassThru) { $session }
	}
}