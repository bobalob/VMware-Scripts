#Gets or Sets VAAI Options on All hosts
Param ( 
  [Switch]$set=$False,
  $Setting=0
)

if ($set) {

  Get-VMHost | %{
    Get-AdvancedSetting $_ -Name DataMover.HardwareAcceleratedMove | 
        Set-AdvancedSetting -Value $Setting -Confirm:$false
    Get-AdvancedSetting $_ -Name DataMover.HardwareAcceleratedInit | 
        Set-AdvancedSetting -Value $Setting -Confirm:$false
    Get-AdvancedSetting $_ -Name VMFS3.HardwareAcceleratedLocking | 
        Set-AdvancedSetting -Value $Setting -Confirm:$false
    Get-AdvancedSetting -Entity $_.Name  -Name VMFS3.UseATSForHBOnVMFS5 | 
        Set-AdvancedSetting -Value $Setting -Confirm:$false
  }

} else {

  Get-VMHost | %{
    Write-Host $_.Name -ForegroundColor Yellow
    Get-AdvancedSetting $_ -Name DataMover.HardwareAcceleratedMove 
    Get-AdvancedSetting $_ -Name DataMover.HardwareAcceleratedInit 
    Get-AdvancedSetting $_ -Name VMFS3.HardwareAcceleratedLocking 
    Get-AdvancedSetting -Entity $_.Name  -Name VMFS3.UseATSForHBOnVMFS5
  }

}
