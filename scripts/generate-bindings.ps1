$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $True

$header = "$PSScriptRoot/../symcrypt-sys/upstream/inc/wrapper.h"
$outDir = "$PSScriptRoot/../symcrypt-sys/src/bindings"

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

$varAllowList = @(
    "^(SYMCRYPT_CODE_VERSION.*)$",
    "^(SYMCRYPT_(SHA3_256|SHA3_384|SHA3_512|SHA256|SHA384|SHA512|SHA1|MD5)_RESULT_SIZE$)",
    "^SymCrypt(?:Sha3_(?:256|384|512)|Sha(?:256|384|512|1)|Md5)Algorithm$",
    "^(SymCryptHmac(Sha256|Sha384|Sha512|Sha1|Md5)Algorithm)$",
    "SymCryptAesBlockCipher",
    "SYMCRYPT_AES_BLOCK_SIZE",
    "^SymCryptEcurveParams(NistP256|NistP384|NistP521|Curve25519)$",
    "SYMCRYPT_FLAG_ECKEY_ECDH",
    "SYMCRYPT_FLAG_ECKEY_ECDSA",
    "SYMCRYPT_FLAG_RSAKEY_ENCRYPT",
    "SYMCRYPT_FLAG_RSAKEY_SIGN",
    "SYMCRYPT_FLAG_RSA_PKCS1_NO_ASN1",
    "SYMCRYPT_FLAG_RSA_PKCS1_OPTIONAL_HASH_OID",
    "^SymCrypt(Sha(1|256|384|512|3_(256|384|512))|Md5)OidList$"
)
$generateVarsParams = @()
foreach ($var in $varAllowList) {
    $generateVarsParams += "--allowlist-var" 
    $generateVarsParams += $var
}

$functionAllowList = @(
    "SymCryptModuleInit",
    "^SymCrypt(?:Sha3_(?:256|384|512)|Sha(?:256|384|512|1)|Md5)(?:Init|Append|Result|StateCopy)?$" ,
    "^SymCryptHmac(?:Sha(?:256|384|512|1)|Md5)(?:ExpandKey|Init|Append|Result|StateCopy)?$" ,
    "^(SymCryptGcm(?:ValidateParameters|ExpandKey|Encrypt|Decrypt|Init|StateCopy|AuthPart|DecryptPart|EncryptPart|EncryptFinal|DecryptFinal)?)$" ,
    "SymCryptChaCha20Poly1305(Encrypt|Decrypt)" ,
    "^SymCryptTlsPrf1_2(?:ExpandKey|Derive)?$" ,
    "^SymCryptAesCbc(Encrypt|Decrypt)?$" ,
    "^SymCryptAesExpandKey$" ,
    "^(SymCryptHkdf.*)$" ,
    "^SymCryptEcurve(Allocate|Free|SizeofFieldElement)$" ,
    "^(SymCryptEckey(Allocate|Free|SizeofPublicKey|SizeofPrivateKey|GetValue|SetRandom|SetValue|SetRandom|))$" ,
    "SymCryptEcDhSecretAgreement" ,
    "^SymCryptRsa.*" ,
    "^(SymCryptEcDsa(Sign|Verify).*)" ,
    "^(SymCryptRsaPkcs1(Sign|Verify|Encrypt|Decrypt).*)$" ,
    "^(SymCryptRsaPss(Sign|Verify).*)$" ,
    "SymCryptWipe" ,
    "SymCryptRandom" ,
    "SymCryptLoadMsbFirstUint64" ,
    "SymCryptStoreMsbFirstUint64"
)
$functionBlockList = @(
     "SymCryptRsakeyCreate" ,
     "SymCryptRsakeySizeofRsakeyFromParams" ,
     "SymCryptRsakeyWipe" ,
     "SymCryptRsaSelftest" ,
     "^SymCryptRsaRaw.*$" 
)
$generateFunctionsParams = @()
foreach ($function in $functionAllowList) {
    $generateFunctionsParams += "--allowlist-function" 
    $generateFunctionsParams += $function
}
foreach ($function in $functionBlockList) {
    $generateFunctionsParams += "--blocklist-function"
    $generateFunctionsParams += $function
}

foreach ($target in $targets) {
    $targetFolder = "$outDir/$($target.Replace("-", "_"))"
    if (Test-Path $targetFolder) {
        Remove-Item $targetFolder -Recurse -Force
    }
    mkdir $targetFolder

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
        -o "$targetFolder/types.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --raw-line "use super::types::*;" `
        --generate vars `
        @generateVarsParams `
        -o "$targetFolder/consts.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --raw-line "use super::types::*;" `
        --generate functions `
        @generateFunctionsParams `
        -o "$targetFolder/fns_source.rs" `
        -- @clangParams

    bindgen `
        $header `
        @bindgenParams `
        --raw-line "use super::types::*;" `
        --dynamic-loading APILoader `
        --generate functions `
        @generateFunctionsParams `
        -o "$targetFolder/fns_libloading.rs" `
        -- @clangParams
}

Remove-Item $header -Force
