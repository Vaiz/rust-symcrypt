# Based on https://github.com/microsoft/vswhere/wiki/Find-VC

[CmdletBinding()]
param (
  [Parameter()]
  $Arch = 'x64',

  [Parameter()]
  $HostArch = 'x64'
)

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vswhere)) {
    Write-Error "vswhere not found"
    exit 1
}

$installDir = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not ($installDir)) {
    Write-Error "Visual Studio not found"
    exit 1
}

$path = join-path $installDir 'VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt'
$version = Get-Content -raw $path
$version = $version.Trim()
$path = join-path $installDir "VC\Tools\MSVC\$version\bin\Host$HostArch\$Arch\cl.exe"
if (-not (Test-Path $path)) {
    Write-Error "cl.exe not found"
    exit 1
}

return $path
