extern crate bindgen;

use std::env;
use std::path::PathBuf;


/// This file is used to generate SymCrypt bindings. We have moved this over to a separate crate because it should only be 
/// used by developers of the symcrypt, and symcrypt-sys crates. Since bindings are maintained and directly checked into
/// symcrypt-sys crate there is no need to have the bindgen bulk included in the symcrypt-sys crate. 


fn main() -> std::io::Result<()> {
    compile_symcrypt()?;

    /*
    println!("cargo:libdir=../SymCrypt/inc"); // SymCrypt *.h files are needed for binding generation. If you are missing this,
    // try pulling SymCrypt as a git module 
    println!("cargo:rerun-if-changed=inc/wrapper.h");

    let bindings = bindgen::Builder::default()
        .header("inc/wrapper.h")
        .clang_arg("-v")
        .parse_callbacks(Box::new(bindgen::CargoCallbacks))
        // ALLOWLIST

        // INIT FUNCTIONS
        .allowlist_function("SymCryptModuleInit")
        .allowlist_var("^(SYMCRYPT_CODE_VERSION.*)$")
        // HASH FUNCTIONS
        .allowlist_function("^SymCrypt(?:Sha3_(?:256|384|512)|Sha(?:256|384|512|1)|Md5)(?:Init|Append|Result|StateCopy)?$")
        .allowlist_var("^(SYMCRYPT_(SHA3_256|SHA3_384|SHA3_512|SHA256|SHA384|SHA512|SHA1|MD5)_RESULT_SIZE$)")
        .allowlist_var("^SymCrypt(?:Sha3_(?:256|384|512)|Sha(?:256|384|512|1)|Md5)Algorithm$")
        // HMAC FUNCTIONS
        .allowlist_function("^SymCryptHmac(?:Sha(?:256|384|512|1)|Md5)(?:ExpandKey|Init|Append|Result|StateCopy)?$")
        .allowlist_var("^(SymCryptHmac(Sha256|Sha384|Sha512|Sha1|Md5)Algorithm)$")
        // GCM FUNCTIONS
        .allowlist_function("^(SymCryptGcm(?:ValidateParameters|ExpandKey|Encrypt|Decrypt|Init|StateCopy|AuthPart|DecryptPart|EncryptPart|EncryptFinal|DecryptFinal)?)$")
        .allowlist_function("SymCryptChaCha20Poly1305(Encrypt|Decrypt)")
        .allowlist_function("^SymCryptTlsPrf1_2(?:ExpandKey|Derive)?$")
        // CBC FUNCTIONS
        .allowlist_function("^SymCryptAesCbc(Encrypt|Decrypt)?$")
        // BLOCK CIPHERS
        .allowlist_var("SymCryptAesBlockCipher")
        .allowlist_function("^SymCryptAesExpandKey$")
        .allowlist_var("SYMCRYPT_AES_BLOCK_SIZE")
        // HKDF FUNCTIONS
        .allowlist_function("^(SymCryptHkdf.*)$") 
        // ECDH KEY AGREEMENT FUNCTIONS
        .allowlist_function("^SymCryptEcurve(Allocate|Free|SizeofFieldElement)$")
        .allowlist_var("^SymCryptEcurveParams(NistP256|NistP384|NistP521|Curve25519)$")
        .allowlist_function("^(SymCryptEckey(Allocate|Free|SizeofPublicKey|SizeofPrivateKey|GetValue|SetRandom|SetValue|SetRandom|))$")
        .allowlist_var("SYMCRYPT_FLAG_ECKEY_ECDH")
        .allowlist_var("SYMCRYPT_FLAG_ECKEY_ECDSA")
        .allowlist_function("SymCryptEcDhSecretAgreement")
        // RSA FUNCTIONS
        .allowlist_function("^SymCryptRsa.*") // Must allow ALL SymCryptRsakey* before blocking the functions that are not needed.
        .blocklist_function("SymCryptRsakeyCreate")
        .blocklist_function("SymCryptRsakeySizeofRsakeyFromParams")
        .blocklist_function("SymCryptRsakeyWipe")
        .blocklist_function("SymCryptRsaSelftest")
        .blocklist_function("^SymCryptRsaRaw.*$")
        .allowlist_var("SYMCRYPT_FLAG_RSAKEY_ENCRYPT")
        .allowlist_var("SYMCRYPT_FLAG_RSAKEY_SIGN")
        // ECDSA functions
        .allowlist_function("^(SymCryptEcDsa(Sign|Verify).*)")
        // RSA PKCS1 FUNCTIONS
        .allowlist_function("^(SymCryptRsaPkcs1(Sign|Verify|Encrypt|Decrypt).*)$")
        .allowlist_var("SYMCRYPT_FLAG_RSA_PKCS1_NO_ASN1")
        .allowlist_var("SYMCRYPT_FLAG_RSA_PKCS1_OPTIONAL_HASH_OID")
        // RSA PSS FUNCTIONS
        .allowlist_function("^(SymCryptRsaPss(Sign|Verify).*)$")
        // OID LISTS
        .allowlist_var("^SymCrypt(Sha(1|256|384|512|3_(256|384|512))|Md5)OidList$")
        // UTILITY FUNCTIONS
        .allowlist_function("SymCryptWipe")
        .allowlist_function("SymCryptRandom")
        .allowlist_function("SymCryptLoadMsbFirstUint64")
        .allowlist_function("SymCryptStoreMsbFirstUint64")    
        
        .generate_comments(true)
        .derive_default(true)
        .generate()
        .expect("Unable to generate bindings");

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("raw_generated_bindings.rs"))
        .expect("Couldn't write bindings!");
     */
    Ok(())
}

fn compile_symcrypt() -> std::io::Result<()> {
    // based on SymCrypt/lib/CMakeLists.txt
    println!("cargo:rerun-if-changed=upstream");
    println!("Compiling SymCrypt...");

    const SOURCE_DIR: &str = "upstream/lib";
    const COMMON_FILES: &[&str] = &[
        "3des.c",
        "a_dispatch.c",
        "aes-asm.c",
        "aes-c.c",
        "aes-default-bc.c",
        "aes-default.c",
        "aes-key.c",
        "aes-neon.c",
        "aes-selftest.c",
        "aes-xmm.c",
        "aes-ymm.c",
        "aescmac.c",
        "aesCtrDrbg.c",
        "aeskw.c",
        "AesTables.c",
        "blockciphermodes.c",
        "ccm.c",
        "chacha20_poly1305.c",
        "chacha20.c",
        "cpuid_notry.c",
        "cpuid_um.c",
        "cpuid.c",
        "crt.c",
        "DesTables.c",
        "desx.c",
        "dh.c",
        "dl_internal_groups.c",
        "dlgroup.c",
        "dlkey.c",
        "dsa.c",
        "ec_dh.c",
        "ec_dispatch.c",
        "ec_dsa.c",
        "ec_internal_curves.c",
        "ec_montgomery.c",
        "ec_mul.c",
        "ec_short_weierstrass.c",
        "ec_twisted_edwards.c",
        "eckey.c",
        "ecpoint.c",
        "ecurve.c",
        "equal.c",
        "FatalIntercept.c",
        "fdef_general.c",
        "fdef_int.c",
        "fdef_mod.c",
        "fdef369_mod.c",
        "fips_selftest.c",
        "gcm.c",
        "gen_int.c",
        "ghash.c",
        "hash.c",
        "hkdf_selftest.c",
        "hkdf.c",
        "hmac.c",
        "hmacmd5.c",
        "hmacsha1.c",
        "hmacsha224.c",
        "hmacsha256.c",
        "hmacsha384.c",
        "hmacsha512.c",
        "hmacsha512_224.c",
        "hmacsha512_256.c",
        "hmacsha3_224.c",
        "hmacsha3_256.c",
        "hmacsha3_384.c",
        "hmacsha3_512.c",
        "kmac.c",
        "libmain.c",
        "lms.c",
        "marvin32.c",
        "md2.c",
        "md4.c",
        "md5.c",
        "mlkem.c",
        "mlkem_primitives.c",
        "modexp.c",
        "paddingPkcs7.c",
        "parhash.c",
        "pbkdf2_hmacsha1.c",
        "pbkdf2_hmacsha256.c",
        "pbkdf2.c",
        "poly1305.c",
        "primes.c",
        "rc2.c",
        "rc4.c",
        "rdrand.c",
        "rdseed.c",
        "recoding.c",
        "rsa_enc.c",
        "rsa_padding.c",
        "rsakey.c",
        "ScsTable.c",
        "scsTools.c",
        "selftest.c",
        "session.c",
        "sha1.c",
        "sha256.c",
        "sha256Par.c",
        "sha256Par-ymm.c",
        "sha256-xmm.c",
        "sha256-ymm.c",
        "sha512.c",
        "sha512Par.c",
        "sha512Par-ymm.c",
        "sha512-ymm.c",
        "sha3.c",
        "sha3_224.c",
        "sha3_256.c",
        "sha3_384.c",
        "sha3_512.c",
        "shake.c",
        "sp800_108_hmacsha1.c",
        "sp800_108_hmacsha256.c",
        "sp800_108_hmacsha512.c",
        "sp800_108.c",
        "srtp_kdf.c",
        "srtp_kdf_selftest.c",
        "ssh_kdf.c",
        "ssh_kdf_sha256.c",
        "ssh_kdf_sha512.c",
        "sskdf.c",
        "sskdf_selftest.c",
        "tlsCbcVerify.c",
        "tlsprf_selftest.c",
        "tlsprf.c",
        "xmss.c",
        "xtsaes.c",
    ];

    let mut cc = cc::Build::new();
    cc.include("upstream/inc").warnings(false);
    for file in COMMON_FILES {
        cc.file(format!("{SOURCE_DIR}/{file}"));
    }

    #[cfg(windows)]
    cc.file(format!("{SOURCE_DIR}/IEEE802_11SaeCustom.c"));
    #[cfg(all(not(windows), target_arch = "x86_64"))]
    cc.file(format!("{SOURCE_DIR}/linux/intrinsics.c"));

    println!("Files to compile: {}", cc.get_files().count());

    cc.compile("symcrypt");

    Ok(())
}