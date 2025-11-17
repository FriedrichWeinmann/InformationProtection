function Set-MipLabel {
	<#
	.SYNOPSIS
		Applies a sensitivity label to a file.
	
	.DESCRIPTION
		Applies a sensitivity label to a file.
		_Downgrading_ a label's security level requires a Justification.
		
		The file being labeled will be temporarily duplicated, meaning ...
		- Write access to the folder is needed, not just the file (specifically, the ability to create a new file)
		- Delete access to the file being labeled is required (to enable rollback in case of error, the file gets renamed, which is essentially a delete & create operation)
		- Exclusive accesss to the file is required
		- Enough storage to copy the file is needed

		Must be connected first using "Connect-InformationProtection".
	
	.PARAMETER Label
		The label to apply.
	
	.PARAMETER Path
		Path to the file to label.
	
	.PARAMETER Justification
		The reason for the label change.
		This is required for any _changes_ to the label that downgrade its protection status.

	.PARAMETER Method
		Whether to consider the label assignment standard or privileged.
		+ Standard: Regular assignment as a user
		+ Privileged: Assignment as an administrative action (e.g. through policies)
		This does not reflect actual protection levels - everybody may pick whatever seems appropriate,
		but a file previously labeled under "Privileged" cannot be relabeled as Standard.
		Defaults to: Privileged (presumably, regular users are not going to be running PowerShell).

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Set-MipLabel -Path .\test.docx -Label 'Highly Confidential\All Employees'

		Updates the label of test.docx to "Highly Confidential\All Employees"

	.EXAMPLE
		PS C:\> Get-ChildItem -Recurse -File | Set-MipLabel -Label Public

		Updates the label on all files in the current folder and subfolders to "Public"
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('InformationProtection.Label')]
		[string]
		$Label,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[PsfFile]
		$Path,

		[string]
		$Justification,

		[Microsoft.InformationProtection.AssignmentMethod]
		$Method = 'Privileged'
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet
		$killIt = $ErrorActionPreference -eq 'Stop'

		$labelObject = Get-MipLabel -Filter $Label
		if (-not $labelObject) {
			Stop-PSFFunction -String 'Set-MipLabel.Error.LabelNotFound' -StringValues $Label -Cmdlet $PSCmdlet -EnableException $true -Category InvalidArgument
		}
		if ($labelObject.ID -contains $Label) { $labelObject = $labelObject | Where-Object ID -eq $Label }
		elseif ($labelObject.FQLN -contains $Label) { $labelObject = $labelObject | Where-Object FQLN -eq $Label }

		if ($labelObject.Count -gt 1) {
			Stop-PSFFunction -String 'Set-MipLabel.Error.LabelAmbiguous' -StringValues $Label, ($labelObject.FQLN -join ', ') -Cmdlet $PSCmdlet -EnableException $true -Category InvalidArgument
		}
	}
	process {
		foreach ($filePath in $Path) {
			$file = [InformationProtection.File]$filePath
			$directory = Split-Path -Path $file.Path
			$fileName = Split-Path -Path $file.Path -Leaf
			$tempNewPath = Join-Path -Path $directory -ChildPath ([Guid]::NewGuid())
			$tempOldName = [Guid]::NewGuid().ToString()
			$tempOldPath = Join-Path -Path $directory -ChildPath $tempOldName
			Invoke-PSFProtectedCommand -ActionString 'Set-MipLabel.ApplyLabel' -ActionStringValues $labelObject.Name, $labelObject.ID -Target $file.Path -ScriptBlock {
				# Step 1: Label & New File
				$file.SetLabel($labelObject.ID, $tempNewPath, $Justification, $Method)

				# Step 2: Rename old file to temp name
				try { Rename-Item -LiteralPath $file.Path -NewName $tempOldName -Force -ErrorAction Stop }
				catch {
					Remove-Item -LiteralPath $tempNewPath -Force
					throw
				}

				# Step 3: Rename labeled file to original name
				try { Rename-Item -LiteralPath $tempNewPath -NewName $fileName -Force -ErrorAction Stop }
				catch {
					# Rollback and delete new file
					Rename-Item -LiteralPath $tempOldPath -NewName $fileName -Force
					Remove-Item -LiteralPath $tempNewPath -Force
					throw
				}

				# Step 4: Delete Renamed unlabeled file
				Remove-Item -LiteralPath $tempOldPath
			} -EnableException $killIt -PSCmdlet $PSCmdlet -Continue
		}
	}
}