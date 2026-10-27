#Requires -RunAsAdministrator
param(
  [string]$BackupPath
)
$ErrorActionPreference = "Stop"

function Find-DockerFrontend {
  try {
    $key = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Docker Desktop" -ErrorAction Stop
    $base = $key.InstallLocation
    if ($base -and (Test-Path (Join-Path $base "frontend\resources\app.asar"))) {
      return (Join-Path $base "frontend")
    }
  } catch {}
  $candidates = @(
    "$env:ProgramFiles\Docker\Docker\frontend",
    "$env:LOCALAPPDATA\Programs\DockerDesktop\frontend"
  )
  foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "resources\app.asar")) { return $c }
  }
  throw "找不到 Docker Desktop 安裝目錄。"
}

$rootBackup = Join-Path $env:LOCALAPPDATA "DockerDesktop-TW\backup"
if (-not $BackupPath) {
  if (-not (Test-Path $rootBackup)) { throw "沒有找到備份目錄: $rootBackup" }
  $BackupPath = Get-ChildItem $rootBackup -Directory | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not (Test-Path (Join-Path $BackupPath "app.asar"))) { throw "備份無效: $BackupPath" }

$Frontend = Find-DockerFrontend
$Res = Join-Path $Frontend "resources"
Write-Host "還原自: $BackupPath"
Write-Host "目標: $Frontend"

try { docker desktop stop 2>$null } catch {}
Get-Process "Docker Desktop","com.docker.backend" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Copy-Item -Force (Join-Path $BackupPath "app.asar") (Join-Path $Res "app.asar")
$up = Join-Path $BackupPath "app.asar.unpacked"
if (Test-Path $up) {
  $destUp = Join-Path $Res "app.asar.unpacked"
  if (Test-Path $destUp) { Remove-Item -Recurse -Force $destUp }
  Copy-Item -Recurse -Force $up $destUp
}
Copy-Item -Force (Join-Path $BackupPath "Docker Desktop.exe") (Join-Path $Frontend "Docker Desktop.exe")
Write-Host "已還原。請手動啟動 Docker Desktop。"
pause
