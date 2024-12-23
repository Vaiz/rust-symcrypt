param (
    [string]$FilePath,
    [string]$OutFormat,
    [string]$ArchDefine
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
Write-Output "OutputAsm: $OutputAsm"

# Preprocessing logic based on OutFormat
if ($OutFormat -eq "gas") {
    throw "gas outformat not implemented"
    # GCC-compatible C compiler
    <#
    $Command = @(
        "gcc", "-E", "-P", "-x", "c", $FilePath, "-o", $OutputAsm,
        @IncludeDirs, "-DSYMCRYPT_GAS", "-D$CppAsmArch", $DbgDefinition
    )
    Write-Host "Running GCC preprocessing: $($Command -join ' ')"
    & $Command
    #>
} elseif ($OutFormat -in @("masm", "armasm64")) {
    # sourced from SymCrypt\msbuild\symcrypt.undocked.props
    $clPath = & "$PSScriptRoot/get-cl-path.ps1"
    & $clPath /EP /P `
        /I "$PSScriptRoot/../symcrypt-sys/upstream/inc" `
        /I "$PSScriptRoot/../symcrypt-sys/upstream/lib" `
        "/D$CppAsmArch" `
        "/DSYMCRYPT_MASM" `
        "/Fi$OutputAsm" `
        $FilePath
} else {
    throw "Unsupported outformat ($OutFormat)"
}

Write-Host "C preprocessing of $FilePath completed. Output: $OutputAsm"
Remove-Item $FilePath
