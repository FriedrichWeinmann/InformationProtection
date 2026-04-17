function New-MipSession {
	<#
	.SYNOPSIS
		Creates a new MP Session used to perform file labelling.
	
	.DESCRIPTION
		Creates a new MP Session used to perform file labelling.
		As opposed to Connect-InformationProtection, this session is not managed by the module as its "default" session.
		This allows maintaining multiple MIP "Connections" - that is, working from the same runspace against multiple tenants.
	
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

	.PARAMETER LogLevel
		The level of details to include in the MIP-integrated logging.
		Logs can be found under "%localappdata%\PowerShell\InformationProtection\logs" or the non-windows equivalent.
		Defaults to: Error.
	
	.EXAMPLE
		PS C:\> New-MipSession

		Authenticate using already established EntraAuth sessions for the services "AzureRightsManagement" and "MIPSyncService".

	.EXAMPLE
		PS C:\> New-MipSession -ClientID $clientID

		Authenticate while creating new EntraAuth sessions for the services "AzureRightsManagement" and "MIPSyncService".
		This will only use the Authorization Code delegate authentication flow.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
					Stop-PSFFunction -String 'New-MipSession.Error.NoTenantId' -Cmdlet $PSCmdlet -EnableException $true -Category InvalidArgument
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
		$session.Authenticate(
			(Get-EntraToken -Service $services.AzureRightsManagement),
			(Get-EntraToken -Service $services.MIPSyncService),
			$logPath,
			$LogLevel
		)
		$session
	}
}