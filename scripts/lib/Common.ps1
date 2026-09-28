#Requires -Version 5.1
<#
.SYNOPSIS
    CasperFix ortak fonksiyonları: log, yedekleme, registry/servis değişikliği, önizleme (DryRun).

.DESCRIPTION
    Tüm modüller registry ve servis değişikliklerini bu dosyadaki fonksiyonlar üzerinden yapar.
    Böylece her değişikliğin önceki değeri backups\<tarih>\state.json dosyasına kaydedilir ve
    99-Restore.ps1 ile geri alınabilir.
#>

Set-StrictMode -Version 2.0

$script:CasperFixRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function Initialize-CasperFix {
    [CmdletBinding()]
    param(
        [switch]$DryRun,
        [switch]$Unattended,
        [switch]$NoBackup
    )

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupDir = Join-Path $script:CasperFixRoot (Join-Path 'backups' $stamp)
    $logDir = Join-Path $script:CasperFixRoot 'logs'
    if (-not $DryRun -and -not $NoBackup) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null

    $global:CasperFix = [pscustomobject]@{
        Root       = $script:CasperFixRoot
        DryRun     = [bool]$DryRun
        Unattended = [bool]$Unattended
        BackupDir  = $backupDir
        LogFile    = Join-Path $logDir "casperfix-$stamp.log"
        State      = [pscustomobject]@{
            Created  = (Get-Date).ToString('s')
            Computer = $env:COMPUTERNAME
            Registry = New-Object System.Collections.ArrayList
            Services = New-Object System.Collections.ArrayList
            Extra    = @{}
        }
    }

    if ($DryRun) {
        Write-CasperLog 'ÖNİZLEME MODU: Hiçbir değişiklik yapılmayacak, sadece yapılacaklar listelenecek.' -Level Warn
    }
}

function Write-CasperLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('Info', 'Ok', 'Warn', 'Error', 'Step')][string]$Level = 'Info'
    )

    $colors = @{ Info = 'Gray'; Ok = 'Green'; Warn = 'Yellow'; Error = 'Red'; Step = 'Cyan' }
    $prefix = @{ Info = '   '; Ok = '[+]'; Warn = '[!]'; Error = '[x]'; Step = '==>' }
    $line = '{0} {1}' -f $prefix[$Level], $Message
    Write-Host $line -ForegroundColor $colors[$Level]

    if ((Test-Path variable:global:CasperFix) -and $global:CasperFix) {
        $stamped = '{0} [{1}] {2}' -f (Get-Date -Format 'HH:mm:ss'), $Level.ToUpper(), $Message
        Add-Content -Path $global:CasperFix.LogFile -Value $stamped -Encoding UTF8
    }
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    if ($global:CasperFix.DryRun) { return }
    if (-not (Test-IsAdmin)) {
        Write-CasperLog 'Bu işlem yönetici yetkisi gerektirir. CasperFix.bat dosyasına sağ tıklayıp "Yönetici olarak çalıştır" seçin.' -Level Error
        throw 'Yönetici yetkisi gerekli.'
    }
}

function Test-DryRun {
    return [bool]$global:CasperFix.DryRun
}

function Read-YesNo {
    <#
        Kullanıcıya evet/hayır sorar. Gözetimsiz (Unattended) veya önizleme modunda
        varsayılan cevabı döndürür.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Question,
        [bool]$Default = $false
    )

    if ($global:CasperFix.Unattended -or $global:CasperFix.DryRun) {
        return $Default
    }
    $hint = if ($Default) { '[E/h]' } else { '[e/H]' }
    $answer = Read-Host "    $Question $hint"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer.Trim().ToLower() -in @('e', 'evet', 'y', 'yes')
}

function Invoke-Change {
    <#
        Registry/servis dışındaki değişiklikler (powercfg, defrag vb.) için sarmalayıcı.
        Önizleme modunda sadece açıklamayı yazar.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][scriptblock]$Action
    )

    if (Test-DryRun) {
        Write-CasperLog "(önizleme) $Description"
        return
    }
    try {
        & $Action
        Write-CasperLog $Description -Level Ok
    }
    catch {
        Write-CasperLog "$Description -> HATA: $($_.Exception.Message)" -Level Error
    }
}

function Set-StateExtra {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Key,
        $Value
    )
    if (-not $global:CasperFix.State.Extra.ContainsKey($Key)) {
        $global:CasperFix.State.Extra[$Key] = $Value
        Save-State
    }
}

function Save-State {
    if (Test-DryRun) { return }
    $path = Join-Path $global:CasperFix.BackupDir 'state.json'
    $global:CasperFix.State | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

function Set-RegValue {
    <#
        Registry değerini yazar; yazmadan önce eski değeri state.json'a kaydeder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet('DWord', 'QWord', 'String', 'ExpandString', 'Binary', 'MultiString')][string]$Type = 'DWord'
    )

    $display = "$Path\$Name = $Value"
    if (Test-DryRun) {
        Write-CasperLog "(önizleme) Registry: $display"
        return
    }

    try {
        $existed = $false
        $oldValue = $null
        $oldKind = $null
        if (Test-Path $Path) {
            $key = Get-Item -Path $Path
            if ($key.GetValueNames() -contains $Name) {
                $existed = $true
                $oldValue = $key.GetValue($Name, $null, 'DoNotExpandEnvironmentNames')
                $oldKind = $key.GetValueKind($Name).ToString()
            }
        }
        else {
            New-Item -Path $Path -Force | Out-Null
        }

        $alreadyRecorded = $global:CasperFix.State.Registry | Where-Object { $_.Path -eq $Path -and $_.Name -eq $Name }
        if (-not $alreadyRecorded) {
            [void]$global:CasperFix.State.Registry.Add([pscustomobject]@{
                    Path     = $Path
                    Name     = $Name
                    Existed  = $existed
                    OldValue = $oldValue
                    OldKind  = $oldKind
                })
            Save-State
        }

        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-CasperLog "Registry: $display" -Level Ok
    }
    catch {
        Write-CasperLog "Registry yazılamadı ($display): $($_.Exception.Message)" -Level Error
    }
}

function Set-ServiceStartup {
    <#
        Servisin başlangıç türünü değiştirir; eski türü state.json'a kaydeder.
        Disabled yapılırsa servis ayrıca durdurulur.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('Automatic', 'Manual', 'Disabled')][string]$StartupType,
        [string]$Reason = ''
    )

    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $svc) {
        Write-CasperLog "Servis bulunamadı, atlanıyor: $Name"
        return
    }

    $label = "Servis $Name ($($svc.DisplayName)) -> $StartupType"
    if ($Reason) { $label += " [$Reason]" }

    $current = (Get-CimInstance -ClassName Win32_Service -Filter "Name='$Name'" -ErrorAction SilentlyContinue).StartMode
    $map = @{ Auto = 'Automatic'; Manual = 'Manual'; Disabled = 'Disabled'; Boot = 'Automatic'; System = 'Automatic' }
    $currentType = if ($current -and $map.ContainsKey($current)) { $map[$current] } else { $null }

    if ($currentType -eq $StartupType) {
        Write-CasperLog "$label (zaten bu durumda)"
        return
    }

    if (Test-DryRun) {
        Write-CasperLog "(önizleme) $label"
        return
    }

    try {
        $alreadyRecorded = $global:CasperFix.State.Services | Where-Object { $_.Name -eq $Name }
        if (-not $alreadyRecorded) {
            [void]$global:CasperFix.State.Services.Add([pscustomobject]@{
                    Name        = $Name
                    OldStartup  = $currentType
                    WasRunning  = ($svc.Status -eq 'Running')
                })
            Save-State
        }

        if ($StartupType -eq 'Disabled' -and $svc.Status -eq 'Running') {
            Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
        }
        Set-Service -Name $Name -StartupType $StartupType -ErrorAction Stop
        Write-CasperLog $label -Level Ok
    }
    catch {
        Write-CasperLog "$label -> HATA: $($_.Exception.Message)" -Level Error
    }
}

function Get-SystemDiskType {
    <#
        Windows'un kurulu olduğu diskin türünü döndürür: 'SSD' veya 'HDD'.
        Tespit edilemezse eski Casper'lar için güvenli seçim olan 'HDD' döner.
    #>
    try {
        $driveLetter = $env:SystemDrive.TrimEnd(':')
        $partition = Get-Partition -DriveLetter $driveLetter -ErrorAction Stop
        $disk = Get-PhysicalDisk -ErrorAction Stop | Where-Object { $_.DeviceId -eq [string]$partition.DiskNumber }
        if ($disk -and $disk.MediaType -eq 'SSD') { return 'SSD' }
        if ($disk -and $disk.MediaType -eq 'HDD') { return 'HDD' }
    }
    catch {
        Write-Verbose "Disk türü tespit edilemedi: $($_.Exception.Message)"
    }
    return 'HDD'
}

function Get-TotalRamGB {
    try {
        $bytes = (Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).TotalPhysicalMemory
        return [math]::Round($bytes / 1GB, 1)
    }
    catch {
        return 0
    }
}

function New-CasperRestorePoint {
    if (Test-DryRun) {
        Write-CasperLog '(önizleme) Sistem geri yükleme noktası oluşturulacak.'
        return
    }
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        # Windows varsayılan olarak 24 saatte bir geri yükleme noktasına izin verir; bu sınırı geçici kaldır.
        $srKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'
        New-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -Value 0 -PropertyType DWord -Force | Out-Null
        Checkpoint-Computer -Description 'CasperFix oncesi' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop
        Remove-ItemProperty -Path $srKey -Name 'SystemRestorePointCreationFrequency' -ErrorAction SilentlyContinue
        Write-CasperLog 'Sistem geri yükleme noktası oluşturuldu: "CasperFix oncesi"' -Level Ok
    }
    catch {
        Write-CasperLog "Geri yükleme noktası oluşturulamadı: $($_.Exception.Message)" -Level Warn
        Write-CasperLog 'Sistem Koruması kapalı olabilir. Registry/servis yedeği yine de alınıyor.' -Level Warn
    }
}
