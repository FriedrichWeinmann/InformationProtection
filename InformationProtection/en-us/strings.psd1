# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Connect-InformationProtection.Error.Authenticate' = 'Failed to authenticate to MIP' #
	'Connect-InformationProtection.Error.Code126'      = "There was an error importing the native MIP libraries. This is usually caused when not installing the VC++ runtime libraries (v14.3+).`nGet the latest version here: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#latest-supported-redistributable-version" #
	'Connect-InformationProtection.Error.NoTenantId'   = 'No or invalid tenant ID provided! Authenticating with a certificate requires both client id and tenant id! See here for details: https://github.com/FriedrichWeinmann/InformationProtection?tab=readme-ov-file#setup-authentication' #

	'New-MipSession.Error.Authenticate'                = 'Failed to authenticate to MIP' #
	'New-MipSession.Error.Code126'                     = "There was an error importing the native MIP libraries. This is usually caused when not installing the VC++ runtime libraries (v14.3+).`nGet the latest version here: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#latest-supported-redistributable-version" #
	'New-MipSession.Error.NoTenantId'                  = 'No Tenant ID provided! When connecting using a certificate, providing a tenant ID becomes mandatory!' #

	'Remove-MipLabel.NotLabeled'                       = 'File "{0}" is not labelled, skipping.' # $filePath
	'Remove-MipLabel.RemoveLabel'                      = 'Removing Label {0} ({1})' # $file.Label.Label.Name, $file.Label.Label.ID

	'Set-MipLabel.Already.Labeled'                     = 'File "{0}" already labeled as {0} ({1}), skipping.' # $filePath, $labelObject.Name, $labelObject.ID
	'Set-MipLabel.ApplyLabel'                          = 'Applying Label {0} ({1})' # $labelObject.Name, $labelObject.ID
	'Set-MipLabel.Error.LabelNotFound'                 = 'Label not found: {0}' # $Label
	'Set-MipLabel.Error.LabelAmbiguous'                = 'Label "{0}" resolved to more than one actual label. Please narrow down your selection to a uniquely identifyable label. Labels matched: {1}' # $Label, ($labelObject.FQLN -join ', ')
}