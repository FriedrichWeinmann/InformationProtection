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
	
	.EXAMPLE
		PS C:\> New-MipSession

		Authenticate using already established EntraAuth sessions for the services "AzureRightsManagement" and "MIPSyncService".

	.EXAMPLE
		PS C:\> New-MipSession -ClientID $clientID

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
		$TenantID = 'organizations'
	)
	begin {
		$services = $script:_serviceSelector.GetServiceMap($ServiceMap)

		if ($ClientID) {
			Connect-EntraService -TenantID $TenantID -ClientID $ClientID -Service $services.AzureRightsManagement
			Connect-EntraService -TenantID $TenantID -ClientID $ClientID -Service $services.MIPSyncService -UseRefreshToken
		}

		Assert-EntraConnection -Cmdlet $PSCmdlet -Service $services.AzureRightsManagement
		Assert-EntraConnection -Cmdlet $PSCmdlet -Service $services.MIPSyncService
	}
	process {
		$logPath = Join-Path -Path (Get-PSFPath -Name LocalAppData) -ChildPath "PowerShell\InformationProtection\logs\$([guid]::NewGuid())"
		$session = [InformationProtection.MipSession]::new()
		$session.Authenticate(
			(Get-EntraToken -Service $services.AzureRightsManagement),
			(Get-EntraToken -Service $services.MIPSyncService),
			$logPath
		)
		$session
	}
}