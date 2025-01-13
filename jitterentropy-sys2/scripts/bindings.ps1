# constants for the bindings generation script
$header = "$PSScriptRoot/../jitterentropy/jitterentropy.h"
$bindings = "$PSScriptRoot/../src/bindings.rs"

$allowedVars = @(
    "JENT_MAJVERSION",
    "JENT_MINVERSION",
    "JENT_PATCHLEVEL",
    "JENT_VERSION"
)

$allowedFunctions = @(
    "jent_entropy_init",
    "jent_entropy_collector_alloc",
    "jent_entropy_collector_free",
    "jent_read_entropy"
)

$clangArgs = @("+A")

$bindgenArgs = @(
    "--raw-line", "use super::handwriten::*;",
    "--ignore-methods",
    "--blocklist-type", "rand_data"    
)

foreach ($var in $allowedVars) {
    $bindgenArgs += "--allowlist-var"
    $bindgenArgs += $var
}
foreach ($function in $allowedFunctions) {
    $bindgenArgs += "--allowlist-function"
    $bindgenArgs += $function
}

bindgen `
    $header `
    @bindgenArgs `
    -o $bindings `
    -- @clangArgs