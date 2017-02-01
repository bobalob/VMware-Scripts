<#
.SYNOPSIS
    Gets snapshot creation and deletion time for a specified VM filter. Requires vSphere PowerCLI
.PARAMETER NumDays
    Filters for the most recent X days of VM logs
.PARAMETER VmFilter
    Filter used on the Get-VM command - you can use wildcards like MyVM-00*
.PARAMETER MaxSamples
    Maximum number of events to parse for each VM, default is 200, may need to increase this if the logs for each VM are very busy
.PARAMETER VIServer
    vCenter Server to connect to
.PARAMETER Credential
    Optional Credential to connect to the vCenter Server
.EXAMPLE
	.\Get-SnapTimes.PS1 -NumDays 1 -VmFilter "supervm*" -VIServer "supervc.example.com" | ft -Auto 
.EXAMPLE
	.\Get-SnapTimes.PS1 -NumDays 3 -VmFilter "supervm*" -VIServer "supervc.example.com" -Credential $MyCreds
#>

Param(
    [Int]
    [Parameter(Mandatory=$true)]
    $NumDays,

    [String]
    [Parameter(Mandatory=$true)]
    $VmFilter,
    
    [Int]
    $MaxSamples=200,

    [String]
    [Parameter(Mandatory=$true)]
    $VIServer,

    [PSCredential]
    $Credential
)
$Snapin = Add-PSSnapin VMware.VimAutomation.Core
if ($Credential) {
    $Connect = Connect-VIServer $VIServer -Credential $Credential -Force
} else {
    $Connect = Connect-VIServer $VIServer -Force
}
$VMs = Get-VM $VmFilter

$VMs | % {$ServerName = $_.Name ; Get-VIEvent -Entity $_ -MaxSamples $MaxSamples} | 
    ? {$_.FullFormattedMessage -match "snapshot"} | ? {$_.CreatedTime -gt (Get-Date).AddDays(-$NumDays)} |
    Select -Property @{Name="Server"; Expression={$ServerName}}, CreatedTime, FullFormattedMessage

