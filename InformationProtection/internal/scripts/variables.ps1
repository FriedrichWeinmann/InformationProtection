$script:_services = @{
	AzureRightsManagement = 'AzureRightsManagement'
	MIPSyncService = 'MIPSyncService'
}
$script:_serviceSelector = New-EntraServiceSelector -DefaultServices $script:_services