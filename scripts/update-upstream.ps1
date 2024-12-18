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

git config --get remote.origin.url > "$destinationDir/VERSION"
git rev-parse HEAD >> "$destinationDir/VERSION"

# TODO: move this logic to build.rs
python "$destinationDir/scripts/version.py" --build-info

# TODO: cleanup unnecessary files
$objects_to_keep = @("inc", "lib", "LICENSE", "NOTICE", "README.md", "SECURITY.md", "VERSION", "version.json")
Get-ChildItem $destinationDir | Where-Object { $_.Name -notin $objects_to_keep } | Remove-Item -Recurse -Force
Remove-Item -Recurse -Force "$destinationDir/.git"
