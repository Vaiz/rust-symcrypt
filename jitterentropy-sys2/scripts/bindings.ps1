# constants for the bindings generation script
$header = "$PSScriptRoot/../jitterentropy/jitterentropy.h"
$bindings = "$PSScriptRoot/../src/bindings.rs"

$allowedFunctions = @(
    "jent_entropy_init",
    "jent_entropy_collector_alloc",
    "jent_entropy_collector_free",
    "jent_read_entropy"
)

$clangArgs = @("+A")

$bindgenArgs = @(
    "--ignore-methods",
    "--allowlist-type", "rand_data",
    "--opaque-type", "rand_data"
)
foreach ($function in $allowedFunctions) {
    $bindgenArgs += "--allowlist-function"
    $bindgenArgs += $function
}

bindgen `
    $header `
    @bindgenArgs `
    -o $bindings `
    -- @clangArgs