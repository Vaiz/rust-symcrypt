$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $True

$header = "$PSScriptRoot/../symcrypt-bindgen/upstream/inc/wrapper.h"
$outDir = "$PSScriptRoot/../symcrypt-sys/bindings"

if ($env:OS -eq "Windows_NT") {
    $targets = @(
        "x86_64-pc-windows-msvc",
        "aarch64-pc-windows-msvc"
        #"x86_64-unknown-linux-gnu",
        #"aarch64-unknown-linux-gnu"
    )
} else {
    $targets = @(
        "x86_64-unknown-linux-gnu",
        "aarch64-unknown-linux-gnu"
    )
}

$wrapperHeader = '
#ifdef __linux__
#include <stddef.h>
#endif

#include "symcrypt.h"
'

$wrapperHeader | Out-File -Encoding utf8 -Force -FilePath $header

foreach ($target in $targets) {
    if (Test-Path "$outDir/$target") {
        Remove-Item "$outDir/$target" -Recurse -Force
    }
    mkdir "$outDir/$target"

    $bindgenParams = @(
        "--generate-block",
        "--no-layout-tests",
        "--no-prepend-enum-name",
        "--with-derive-eq",
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-ord",
        "--use-array-pointers-in-arguments"
        #"--formatter=none"
    )
    $clangParams = @(
        "-v",
        "-target", $target
    )

    bindgen `
        $header `
        @bindgenParams `
        --generate types `
        -o "$outDir/$target/types.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --generate vars `
        -o "$outDir/$target/consts.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --raw-line "use super::types::*;" `
        --generate functions `
        -o "$outDir/$target/fns_source.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --raw-line "use super::types::*;" `
        --dynamic-loading APILoader `
        --generate functions `
        -o "$outDir/$target/fns_libloading.rs" `
        -- @clangParams
}

Remove-Item $header -Force