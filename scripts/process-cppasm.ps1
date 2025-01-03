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
$RootPath = [System.IO.Path]::GetDirectoryName($FilePath)
$FileStem = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
$CppAsmArch = "SYMCRYPT_CPU_" + $ArchDefine.ToUpper()
$OutputAsm = Join-Path $RootPath "$FileStem.asm"

Write-Output "Triple: $TargetTriple"
Write-Output "OutputAsm: $OutputAsm"

# Preprocessing logic based on OutFormat
if ($OutFormat -eq "gas") {
    # GCC-compatible C compiler
    $gcc = "~\AppData\Local\Microsoft\WinGet\Packages\MartinStorsjo.LLVM-MinGW.MSVCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\llvm-mingw-20241217-msvcrt-x86_64\bin\gcc.EXE"
    & $gcc -E -P -x c $FilePath `
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
Remove-Item $FilePath
