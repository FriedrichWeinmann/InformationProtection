# Changelog

## ???

+ New: Get-MipLabel - Returns the currently established MIP session.
+ New: Remove-MipLabel - makes it all go away
+ Upd: Connect-InformationProtection - Enables specifying the email address used for metadata on labeled files.
+ Upd: Set-MipLabel - no longer clears files to 0 bytes when applying the same label again.

## 1.0.11 (2026-03-12)

+ New: Disconnect-InformationProtection - Disconnects from MIP.
+ New: New-MipSession - Creates a new MP Session used to perform file labelling.
+ New: Import-MipSession - Uses a provided MipSession as the default session used by the module.
+ New: Added support for ARM OS-Architectures
+ Upd: Connections are now runspace-specific and no longer process-wide, allowing concurrent connections to different tenants & parallelized operations.
+ Upd: MIP SDK - Update to v1.18.103
+ Fix: Connect-InformationProtection - crashes console when connecting again.

## 0.9.4 (2025-11-17)

+ Upd: Set-MipLabel - added "Method" parameter, to enable Privileged labelling
+ Upd: Get-MipLabel - improved output display result, when showing the labeling status of a file

## 0.9.2 (2025-09-12)

+ Upd: Label Object - Renamed "FQLA" property to "FQLN"
+ Fix: Log Path - Changed to LocalAppData from current path

## 0.9.0 (2025-09-12)

+ Initial Release
