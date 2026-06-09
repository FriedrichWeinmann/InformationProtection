# Changelog

## 1.0.20 (2026-06-09)

+ Fix: Connect-InformationProtection - Handles assembly load errors when connecting, especially without the VC++ runtime missing.
+ Fix: New-MipSession - Handles assembly load errors when connecting, especially without the VC++ runtime missing.

## 1.0.18 (2026-04-20)

+ Fix: New-MipSession - fails to create a session

## 1.0.17 (2026-04-16)

+ New: Get-MipSession - Returns the currently established MIP session.
+ New: Remove-MipLabel - makes it all go away
+ Upd: Connect-InformationProtection - Add support for a `-Certificate` parameter to simplify application authentication
+ Upd: Connect-InformationProtection - Enables specifying the email address used for metadata on labeled files.
+ Upd: Set-MipLabel - no longer clears files to 0 bytes when applying the same label again.
+ Upd: Set-MipLabel - updates the extension in the same way the desktop client would (.txt -> .ptxt, etc.)

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
