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
git -C $destinationDir submodule update --init -- 3rdparty/jitterentropy-library

# VERSION file
$versionFile = Join-Path $destinationDir "VERSION"
"SymCrypt" > $versionFile
git -C $destinationDir config --get remote.origin.url >> $versionFile
git -C $destinationDir rev-parse HEAD >> $versionFile
$tag >> $versionFile
"" >> $versionFile
"jitterentropy" >> $versionFile
git -C $destinationDir/3rdparty/jitterentropy-library config --get remote.origin.url >> $versionFile
git -C $destinationDir/3rdparty/jitterentropy-library rev-parse HEAD >> $versionFile

# TODO: move this logic to build.rs
python3 "$destinationDir/scripts/version.py" --build-info

# WIN32_amd64
$asmSettings = @(
    @("x86_64-pc-windows-msvc", "$destinationDir/lib/amd64", "amd64", "masm", "msft"),
    @("aarch64-pc-windows-msvc", "$destinationDir/lib/arm64", "arm64", "armasm64", "aapcs64")
    @("x86_64-unknown-linux-gnu", "$destinationDir/lib/amd64", "amd64", "gas", "systemv"),
    @("aarch64-unknown-linux-gnu","$destinationDir/lib/arm64", "arm64", "gas", "aapcs64")
)

foreach ($settings in $asmSettings) {
    $triple = $settings[0]; $dir = $settings[1]; $arch = $settings[2]; $outFormat = $settings[3]; 
    $callingConvention = $settings[4]
    
    $symcryptasm = Get-ChildItem $dir -Filter *.symcryptasm;
    foreach ($file in $symcryptasm) {
        & "$PSScriptRoot/process-symcryptasm.ps1" `
            -FilePath $file.FullName `
            -OutFormat $outFormat `
            -ArchDefine $arch `
            -CallingConvention $callingConvention `
            -TargetTriple $triple
    }
}

# TODO: cleanup unnecessary files
$objects_to_keep = @(
    "3rdparty", "inc", "lib", "modules",
    "LICENSE", "NOTICE", "README.md", "SECURITY.md", "VERSION", "version.json"
)
Get-ChildItem $destinationDir | Where-Object { $_.Name -notin $objects_to_keep } | Remove-Item -Recurse -Force

$suffixes_to_remove = @("CMakeLists.txt", ".cppasm", ".symcryptasm", ".vcxproj")
foreach ($suffix in $suffixes_to_remove) {
    Get-ChildItem $destinationDir -Recurse -Filter *$suffix | Remove-Item -Recurse -Force
}

Remove-Item -Recurse -Force "$destinationDir/.git"
