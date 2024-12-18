$header = "$PSScriptRoot/../symcrypt-bindgen/upstream/inc/wrapper.h"
$outDir = "$PSScriptRoot/../symcrypt-sys/bindings"

# $targets = @("linux_amd64", "linux_arm64", "windows_amd64", "windows_arm64")

$wrapperHeader = '
#ifdef __linux__
#include <stddef.h>
#endif

#include "symcrypt.h"
'

$wrapperHeader | Out-File -Encoding utf8 -FilePath $header

$target = "windows_amd64"
mkdir "$outDir/$target" -ErrorAction Stop

bindgen `
    $header `
    --generate-block `
    --no-layout-tests `
    --no-prepend-enum-name `
    --with-derive-eq --with-derive-default --with-derive-hash --with-derive-ord `
    --use-array-pointers-in-arguments `
    --generate types `
    -o "$outDir/$target/types.rs"

bindgen `
    $header `
    --generate-block `
    --no-layout-tests `
    --no-prepend-enum-name `
    --with-derive-eq --with-derive-default --with-derive-hash --with-derive-ord `
    --use-array-pointers-in-arguments `
    --generate vars `
    -o "$outDir/$target/consts.rs"

bindgen `
    $header `
    --generate-block `
    --no-layout-tests `
    --no-prepend-enum-name `
    --with-derive-eq --with-derive-default --with-derive-hash --with-derive-ord `
    --use-array-pointers-in-arguments `
    --raw-line "use super::types::*;" `
    --generate functions `
    -o "$outDir/$target/fns_source.rs"

bindgen `
    $header `
    --generate-block `
    --no-layout-tests `
    --no-prepend-enum-name `
    --with-derive-eq --with-derive-default --with-derive-hash --with-derive-ord `
    --use-array-pointers-in-arguments `
    --raw-line "use super::types::*;" `
    --dynamic-loading APILoader `
    --generate functions `
    -o "$outDir/$target/fns_libloading.rs"