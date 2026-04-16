<#
A bit of an idiosyncracy of loading libraries on ARM CPUs:
We need to load the ARM-specific native libraries, we can't load them explicitly and the PInvoke from Microsoft.InformationProtection will use the default assembly resolution mechanisms.
The default assembly resolution mechanism on Windows does not actually care about CPU architectures and will instead determine between x64 and x86 based on _process_ type (64bit or 32bit, respectively).

Hence we need to create a subfolder under ARM named x64 and push the binaries there.
#>

[CmdletBinding()]
param (
	
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Warning "Script failed: $_"
	throw $_
}


$projectRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot))
$armRoot = Join-Path -Path $projectRoot -ChildPath 'InformationProtection\bin\arm64'
$armX64Path = Join-Path -Path $projectRoot -ChildPath 'InformationProtection\bin\arm64\x64'

$files = Get-ChildItem -LiteralPath $armRoot -File | Where-Object BaseName -ne 'Microsoft.InformationProtection'
if (-not $files) { return }

Remove-Item -Path "$armX64Path\*"
$files | Move-Item -Destination $armX64Path

