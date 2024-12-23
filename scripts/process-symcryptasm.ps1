param (
    [string]$FilePath,
    [string]$OutFormat,
    [string]$ArchDefine,
    [string]$CallingConvention
)

# Validate file extension
$FileExtension = [System.IO.Path]::GetExtension($FilePath)
if ($FileExtension -ne ".symcryptasm") {
    throw "symcryptasm processing invoked on file with incorrect extension ($FilePath -> $FileExtension)"
}

# Validate OutFormat
if ($OutFormat -notin @("gas", "masm", "armasm64")) {
    throw "symcryptasm processing invoked with unrecognized outformat ($OutFormat)"
}

# Validate ArchDefine
if ($ArchDefine -notin @("amd64", "x86", "arm64", "arm")) {
    throw "symcryptasm processing invoked with unrecognized archdefine ($ArchDefine)"
}

# Validate CallingConvention
if ($CallingConvention -notin @("msft", "systemv", "aapcs64", "arm64ec", "aapcs32")) {
    throw "symcryptasm processing invoked with unrecognized callingconvention ($CallingConvention)"
}

# Get directory and file name components
$RootPath = [System.IO.Path]::GetDirectoryName($FilePath)
$FileStem = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
$OutputCppAsm = Join-Path $RootPath "$FileStem.cppasm"
Write-Output "OutputCppAsm: $OutputCppAsm"

# Run the Python script
$PythonScript = "$PSScriptRoot/../symcrypt-sys/upstream/scripts/symcryptasm_processor.py"
& python $PythonScript $OutFormat $ArchDefine $CallingConvention $FilePath $OutputCppAsm
& "$PSScriptRoot/process-cppasm.ps1" $OutputCppAsm $OutFormat $ArchDefine
