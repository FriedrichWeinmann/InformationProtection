# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Set-MipLabel.Error.LabelNotFound' = 'Label not found: {0}' # $Label
	'Set-MipLabel.Error.LabelAmbiguous' = 'Label "{0}" resolved to more than one actual label. Please narrow down your selection to a uniquely identifyable label. Labels matched: {1}' # $Label, ($labelObject.FQLN -join ', ')
	'Set-MipLabel.ApplyLabel' = 'Applying Label {0} ({1})' # $labelObject.Name, $labelObject.ID
}