[CmdletBinding()]
param(
    [string] $tag = "v103.6.0"
)

$repoUrl = "https://github.com/microsoft/SymCrypt.git"
$destinationDir = "$PSScriptRoot/../symcrypt-bindgen/upstream"

if (Test-Path $destinationDir) {
    Remove-Item $destinationDir -Recurse -Force
}
git clone --branch $tag --depth 1 $repoUrl $destinationDir

# TODO: move this logic to build.rs
python "$destinationDir/scripts/version.py" --build-info

# TODO: cleanup unnecessary files