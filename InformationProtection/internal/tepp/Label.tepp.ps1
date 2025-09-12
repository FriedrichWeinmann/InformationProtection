Register-PSFTeppScriptblock -Name 'InformationProtection.Label' -ScriptBlock {
	foreach ($label in Get-MipLabel) {
		if (-not $label.IsActive) { continue }

		$toolTip = $label.FQLA
		if ($label.Description) { $toolTip = "$($toolTip) | $($label.Description)"	}

		@{ Text = $label.FQLA; ToolTip = $toolTip }
	}
} -Global