[CmdletBinding()]
param(
    [string] $tag = "v103.6.0"
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

# TODO: move this logic to build.rs
python "$destinationDir/scripts/version.py" --build-info

# WIN32_amd64
$symcryptasm = Get-ChildItem "$destinationDir/lib/amd64" -Filter *.symcryptasm;
foreach ($file in $symcryptasm) {
    & "$PSScriptRoot/process-symcryptasm.ps1" `
        -FilePath $file.FullName `
        -OutFormat masm `
        -ArchDefine amd64 `
        -CallingConvention msft
}

# TODO: cleanup unnecessary files
$objects_to_keep = @(
    "inc", "lib", "modules",
    "LICENSE", "NOTICE", "README.md", "SECURITY.md", "VERSION", "version.json"
)
Get-ChildItem $destinationDir | Where-Object { $_.Name -notin $objects_to_keep } | Remove-Item -Recurse -Force
Remove-Item -Recurse -Force "$destinationDir/.git"
