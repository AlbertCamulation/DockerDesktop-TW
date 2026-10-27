#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Apply Traditional Chinese (Taiwan) localization to the installed Docker Desktop.
  Builds from THIS MACHINE's official Docker Desktop files using DDCS; does not download prebuilt app.asar.
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Root "ddcs.py"))) { $Root = $PSScriptRoot }
Set-Location $Root

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
  throw "找不到 Docker Desktop 安裝目錄（resources\app.asar）。"
}

$Frontend = Find-DockerFrontend
$Res = Join-Path $Frontend "resources"
$Exe = Join-Path $Frontend "Docker Desktop.exe"
Write-Host "Docker frontend: $Frontend"

# version hint
$ver = "unknown"
try { $ver = (& docker desktop version 2>$null) -join " " } catch {}
Write-Host "Docker Desktop: $ver"

# deps
if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw "需要 Python >= 3.10" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw "需要 Node.js >= 22" }
python -c "import sys; assert sys.version_info >= (3,10)" 
$nv = (node -v).TrimStart("v").Split(".")[0]
if ([int]$nv -lt 22) { throw "需要 Node.js >= 22，目前: $(node -v)" }

Write-Host "安裝 Python / npm 依賴（略過 postinstall scripts）..."
python -m pip install -r requirements.txt
if (Test-Path "package.json") { npm install --ignore-scripts }

# stop docker
Write-Host "停止 Docker Desktop..."
try { docker desktop stop 2>$null } catch {}
Get-Process "Docker Desktop","com.docker.backend" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# backup
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$Backup = Join-Path $env:LOCALAPPDATA "DockerDesktop-TW\backup\$stamp"
New-Item -ItemType Directory -Force -Path $Backup | Out-Null
Copy-Item -Force (Join-Path $Res "app.asar") (Join-Path $Backup "app.asar")
if (Test-Path (Join-Path $Res "app.asar.unpacked")) {
  Copy-Item -Recurse -Force (Join-Path $Res "app.asar.unpacked") (Join-Path $Backup "app.asar.unpacked")
}
Copy-Item -Force $Exe (Join-Path $Backup "Docker Desktop.exe")
Set-Content -Encoding UTF8 (Join-Path $Backup "INFO.txt") "frontend=$Frontend`nversion=$ver`ntime=$stamp"
Write-Host "已備份到: $Backup"

Write-Host "執行漢化（僅字串替換 + 更新 asar 完整性 hash）..."
$env:PYTHONIOENCODING = "utf-8"
python ddcs.py
if ($LASTEXITCODE -ne 0) { throw "ddcs.py 失敗，exit=$LASTEXITCODE。請從備份還原。" }

Write-Host "完成。可手動啟動 Docker Desktop。"
Write-Host "還原請執行: scripts\Restore-Original.ps1 -BackupPath `"$Backup`""
pause
