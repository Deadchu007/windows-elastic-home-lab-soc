# Read-only Windows host baseline for the Elastic home-lab SOC.
# It prints a concise summary and does not change settings or write files.

$ErrorActionPreference = 'Stop'

function Show-Section {
  param([string]$Title, [scriptblock]$Query)
  Write-Output "=== $Title ==="
  try {
    $result = @(& $Query)
    if ($result.Count -gt 0) { $result }
    else { Write-Output 'No data returned.' }
  } catch {
    Write-Output ("Query failed: " + $_.Exception.Message)
  }
}

Show-Section 'Windows version' { Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber }

Show-Section 'Firewall profiles' { Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction }

Show-Section 'Microsoft Defender' { Get-MpComputerStatus | Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, AntispywareEnabled, AntivirusSignatureLastUpdated }

Show-Section 'Remote Desktop' {
  $rdp = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections
  [pscustomobject]@{ RDPEnabled = ($rdp.fDenyTSConnections -eq 0) }
}

Show-Section 'System drive encryption' { Get-BitLockerVolume -MountPoint $env:SystemDrive | Select-Object MountPoint, VolumeStatus, ProtectionStatus, EncryptionPercentage }

Show-Section 'Recent installed hotfixes' { Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID, InstalledOn, Description }

Show-Section 'System drive free space (GB)' {
  $driveLetter = $env:SystemDrive.TrimEnd(':')
  Get-Volume -DriveLetter $driveLetter | Select-Object DriveLetter, FileSystem, HealthStatus,
    @{Name='FreeGB';Expression={[math]::Round($_.SizeRemaining / 1GB, 1)}},
    @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 1)}}
}

Show-Section 'Local Administrators members' { Get-LocalGroupMember -Group 'Administrators' | Select-Object Name, ObjectClass, PrincipalSource }

Show-Section 'Listening TCP ports' { Get-NetTCPConnection -State Listen | Select-Object -ExpandProperty LocalPort -Unique | Sort-Object }
