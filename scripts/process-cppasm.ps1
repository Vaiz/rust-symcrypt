param (
    [string]$FilePath,
    [string]$OutFormat,
    [string]$ArchDefine,
    [string]$TargetTriple
)

# Validate file extension
$FileExtension = [System.IO.Path]::GetExtension($FilePath)
if ($FileExtension -ne ".cppasm") {
    throw "cppasm processing invoked on file with incorrect extension ($FilePath -> $FileExtension)"
}

# Validate OutFormat
if ($OutFormat -notin @("gas", "masm", "armasm64")) {
    throw "cppasm processing invoked with unrecognized outformat ($OutFormat)"
}

# Validate ArchDefine
if ($ArchDefine -notin @("amd64", "x86", "arm64", "arm")) {
    throw "cppasm processing invoked with unrecognized archdefine ($ArchDefine)"
}

# Get directory and file name components
$RootPath = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetDirectoryName($FilePath))
$AsmDir = Join-Path $RootPath asm $TargetTriple
$FileStem = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
$CppAsmArch = "SYMCRYPT_CPU_" + $ArchDefine.ToUpper()
if ($OutFormat -eq "gas") {
    $OutputAsm = Join-Path $AsmDir "$FileStem-gas.asm"
} else {
    $OutputAsm = Join-Path $AsmDir "$FileStem.asm"
}

if (-not (Test-Path $AsmDir)) {
    New-Item -ItemType Directory -Path $AsmDir | Out-Null
}

Write-Output "Triple: $TargetTriple"
Write-Output "OutputAsm: $OutputAsm"

# Preprocessing logic based on OutFormat
if ($OutFormat -eq "gas") {
    # GCC-compatible C compiler
    clang -E -P -x c $FilePath `
        -o $OutputAsm `
        -D SYMCRYPT_GAS `
        -D $CppAsmArch `
        -I "$PSScriptRoot/../symcrypt-sys/upstream/inc" `
        -I "$PSScriptRoot/../symcrypt-sys/upstream/lib" `
        -target $TargetTriple
} elseif ($OutFormat -in @("masm", "armasm64")) {
    # sourced from SymCrypt\msbuild\symcrypt.undocked.props
    $clPath = & "$PSScriptRoot/get-cl-path.ps1"
    & $clPath /EP /P `
        /I "$PSScriptRoot/../symcrypt-sys/upstream/inc" `
        /I "$PSScriptRoot/../symcrypt-sys/upstream/lib" `
        /I "C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\shared" `
        "/D$CppAsmArch" `
        "/DSYMCRYPT_MASM" `
        "/Fi$OutputAsm" `
        $FilePath
} else {
    throw "Unsupported outformat ($OutFormat)"
}

Write-Host "C preprocessing of $FilePath completed. Output: $OutputAsm"

if ($env:KEEP_CPPASM -ne "1") {    
    Remove-Item $FilePath
}
