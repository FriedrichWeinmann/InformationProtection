function Remove-MipLabel {
	<#
	.SYNOPSIS
		Strips MIP labels from files.
	
	.DESCRIPTION
		Strips MIP labels from files.
		Generally NOT something we want to do, but sometimes it becomes necessary.
	
	.PARAMETER Path
		Path to the file to unlabel.
	
	.PARAMETER Justification
		The reason for the label removal.
	
	.PARAMETER Method
		Whether to consider the label removal action standard or privileged.
		+ Standard: Regular removal as a user
		+ Privileged: Removal as an administrative action (e.g. through policies)
		This does not reflect actual protection levels - everybody may pick whatever seems appropriate,
		but a file previously labeled under "Privileged" cannot be unlabeled as Standard.
		Defaults to: Privileged (presumably, regular users are not going to be running PowerShell).
	
	.PARAMETER Session
		MIP Session to use for the operation.
		Overrides the use of the default session and would be used in situations when relabeling files from one tenant to another.
		Use "New-MipSession" to create a standalone session object.
	
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
	
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

	.EXAMPLE
		PS C:\> Remove-MipLabel -Path .\test.docx

		Removes the label of test.docx.

	.EXAMPLE
		PS C:\> Get-ChildItem -Recurse -File | Remove-MipLabel

		Removes the label on all files in the current folder and subfolders.
	#>
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[PsfFile]
		$Path,

		[Parameter(Mandatory = $true)]
		[string]
		$Justification,

		[Microsoft.InformationProtection.AssignmentMethod]
		$Method = 'Privileged',

		[InformationProtection.MipSession]
		$Session
	)
	begin {
		Assert-MIPConnection -Cmdlet $PSCmdlet -Session $Session
		$sessionToUse = $script:_session
		if ($Session.Context) { $sessionToUse = $Session }

		$killIt = $ErrorActionPreference -eq 'Stop'
	}
	process {
		foreach ($filePath in $Path) {
			try { $file = Get-MipFile -Path $filePath -Session $sessionToUse -ErrorAction Stop }
			catch {
				Write-Error $_
				continue
			}
			if (-not $file.Label) {
				Write-PSFMessage -Level Verbose -String 'Remove-MipLabel.NotLabeled' -StringValues $filePath
				continue
			}
			$directory = Split-Path -Path $file.Path
			$fileName = Split-Path -Path $file.Path -Leaf
			$fileNewName = $file.FileNameUnprotected
			$tempNewPath = Join-Path -Path $directory -ChildPath ([Guid]::NewGuid())
			$tempOldName = [Guid]::NewGuid().ToString()
			$tempOldPath = Join-Path -Path $directory -ChildPath $tempOldName
			Invoke-PSFProtectedCommand -ActionString 'Remove-MipLabel.RemoveLabel' -ActionStringValues $file.Label.Label.Name, $file.Label.Label.ID -Target $file.Path -ScriptBlock {
				# Step 1: Label & New File
				$file.RemoveLabel($tempNewPath, $Justification, $Method)
				$file.Handler.Dispose()

				# Step 2: Rename old file to temp name
				try { Rename-Item -LiteralPath $filePath -NewName $tempOldName -Force -ErrorAction Stop }
				catch {
					Remove-Item -LiteralPath $tempNewPath -Force
					throw
				}

				# Step 3: Rename labeled file to original name
				try { Rename-Item -LiteralPath $tempNewPath -NewName $fileNewName -Force -ErrorAction Stop }
				catch {
					# Rollback and delete new file
					Rename-Item -LiteralPath $tempOldPath -NewName $fileName -Force
					Remove-Item -LiteralPath $tempNewPath -Force
					throw
				}

				# Step 4: Delete Renamed unlabeled file
				Remove-Item -LiteralPath $tempOldPath
			} -EnableException $killIt -PSCmdlet $PSCmdlet -Continue -ErrorEvent {
				$file.Handler.Dispose()
			}
		}
	}
}