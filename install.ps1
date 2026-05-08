# ACA CLI Installer for Windows
param(
    [string]$Version = "latest",
    [string]$InstallDir = "$env:USERPROFILE\.aca\bin",
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$Repo = "annaji-msft/aca"
$BinaryName = "aca"

function Uninstall-Aca {
    $ExePath = Join-Path $InstallDir "$BinaryName.exe"
    if (-not (Test-Path $ExePath)) {
        Write-Host "$BinaryName is not installed at $ExePath"
        return
    }

    Remove-Item -Force $ExePath
    Write-Host "Removed $ExePath"

    # Clean up PATH and directory if empty
    $Remaining = Get-ChildItem $InstallDir -ErrorAction SilentlyContinue
    if (-not $Remaining) {
        Remove-Item -Force $InstallDir -ErrorAction SilentlyContinue
        $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($UserPath -like "*$InstallDir*") {
            $NewPath = ($UserPath -split ';' | Where-Object { $_ -ne $InstallDir }) -join ';'
            [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")
            Write-Host "Removed $InstallDir from PATH."
        }
    }

    Write-Host "$BinaryName uninstalled successfully."
}

function Install-Aca {
    $Platform = "win-x64"

    if ($Version -eq "latest") {
        $Release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -UseBasicParsing
        $Version = $Release.tag_name
        Write-Host "Latest version: $Version"
    }
    $Url = "https://github.com/$Repo/releases/download/$Version/$BinaryName-$Version-$Platform.zip"

    Write-Host "Downloading $BinaryName from $Url..."

    # Create install directory
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    $TmpFile = Join-Path $env:TEMP "$BinaryName-$Platform.zip"
    $TmpDir = Join-Path $env:TEMP "$BinaryName-extract"

    try {
        Invoke-WebRequest -Uri $Url -OutFile $TmpFile -UseBasicParsing
        
        if (Test-Path $TmpDir) { Remove-Item -Recurse -Force $TmpDir }
        Expand-Archive -Path $TmpFile -DestinationPath $TmpDir -Force

        Copy-Item -Path (Join-Path $TmpDir "$BinaryName.exe") -Destination (Join-Path $InstallDir "$BinaryName.exe") -Force
    } finally {
        Remove-Item -Force $TmpFile -ErrorAction SilentlyContinue
        Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
    }

    # Add to PATH if not already there
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($UserPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
        $env:PATH = "$env:PATH;$InstallDir"
        Write-Host "Added $InstallDir to PATH."
    }

    Write-Host ""
    Write-Host "$BinaryName installed successfully to $InstallDir\$BinaryName.exe"
    Write-Host "Restart your terminal, then run '$BinaryName --help' to get started."
}

if ($Uninstall) {
    Uninstall-Aca
} else {
    Install-Aca
}
