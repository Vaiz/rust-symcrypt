[CmdletBinding()]
param(
    [string] $tag = "v103.4.2"
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $True

$repoUrl = "https://github.com/microsoft/SymCrypt.git"
$destinationDir = "$PSScriptRoot/../symcrypt-sys/upstream"

if (Test-Path $destinationDir) {
    Remove-Item $destinationDir -Recurse -Force
}
git clone --branch $tag --depth 1 $repoUrl $destinationDir

git config --get remote.origin.url > "$destinationDir/VERSION"
git rev-parse HEAD >> "$destinationDir/VERSION"
$tag >> "$destinationDir/VERSION"

# TODO: move this logic to build.rs
python "$destinationDir/scripts/version.py" --build-info

# WIN32_amd64
$asmSettings = @(
    @("$destinationDir/lib/amd64", "amd64", "masm", "msft"),
    @("$destinationDir/lib/arm64", "arm64", "armasm64", "aapcs64")
)

foreach ($settings in $asmSettings) {
    $dir = $settings[0]; $arch = $settings[1]; $outFormat = $settings[2]; $callingConvention = $settings[3]
    $symcryptasm = Get-ChildItem $dir -Filter *.symcryptasm;
    foreach ($file in $symcryptasm) {
        & "$PSScriptRoot/process-symcryptasm.ps1" `
            -FilePath $file.FullName `
            -OutFormat $outFormat `
            -ArchDefine $arch `
            -CallingConvention $callingConvention
    }
}

# TODO: cleanup unnecessary files
$objects_to_keep = @(
    "inc", "lib", "modules",
    "LICENSE", "NOTICE", "README.md", "SECURITY.md", "VERSION", "version.json"
)
Get-ChildItem $destinationDir | Where-Object { $_.Name -notin $objects_to_keep } | Remove-Item -Recurse -Force
Remove-Item -Recurse -Force "$destinationDir/.git"
