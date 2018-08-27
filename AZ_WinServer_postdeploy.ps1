<#

AZ_WinServer_postdeploy.ps1

These are tasks that will run on a newly-created Windows Server 2016 VM after
using a script such as
\\nblenergy.com\server\Software\scripts\AZ_create_prod_VM_and_join_domain.ps1
which uses the AzureRM template
\\nblenergy.com\server\Software\scripts\AZP_Win2016.json. The template is
configured to use an AzureRM Extension named NBLCustomDeploy which is using a
Microsoft.Compute extension called CustomScriptExtension to run PowerShell and
this script (as specified by AZ_create_prod_VM_and_join_domain.ps1, for
example).

Note that the new VM will not be joined yet to Active Directory by the time the
template runs this script, so do not include any tasks here that depend on AD
membership.

This script should be located in the Azure storage account named
"scriptssouthcentral", specifically in a blob container folder named "scripts".
The storage account is in the "NBL PROD A" environment.


Last updated 11/7/2017 by Ken Puckett

#>

Set-Timezone -Name "Central Standard Time"

New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform' `
  -Name 'KeyManagementServiceName' `
  -PropertyType String `
  -Value 'hou-lic3.nblenergy.com' `
  -Force

Install-WindowsFeature rsat-adds,rsat-ad-powershell,telnet-client

Get-NetFirewallRule -displaygroup 'File and Printer Sharing' | enable-netfirewallrule
Enable-NetFirewallRule -Name WMI-RPCSS-In-TCP,WMI-WINMGMT-In-TCP,WMI-WINMGMT-Out-TCP,WMI-ASYNC-In-TCP

# The template that this script is associated with creates a data drive that
# needs to be initialized. This next line looks for that new drive (it will
# have an initial partition style of "raw"), initializes it as a GPT disk,
# creates a partition on the disk using all available disk space, assigns it
# the next available drive letter, and formats it as an NTFS volume.
Get-Disk | Where partitionstyle -eq raw | Initialize-Disk -PartitionStyle GPT -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false
