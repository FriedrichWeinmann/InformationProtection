$script:_services = @{
	AzureRightsManagement = 'AzureRightsManagement'
	MIPSyncService = 'MIPSyncService'
}
$script:_serviceSelector = New-EntraServiceSelector -DefaultServices $script:_services

# The current Runspace's default MIP Session
$script:_session = $null