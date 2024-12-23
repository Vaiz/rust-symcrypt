#![allow(unused_imports)] // FIXME: Remove this line after removing the unused import

#[cfg(target_os = "windows")]
use std::env;

fn main() -> std::io::Result<()> {
    compile_and_link_symcrypt()?;

    /*
    #[cfg(target_os = "windows")]
    {
        // Look for the .lib file during link time. We are searching the Windows/System32 path which is set as a current default to match
        // the long term placement of a Windows shipped symcrypt.dll

        #let lib_path = env::var("SYMCRYPT_LIB_PATH")
            .unwrap_or_else(|_| panic!("SYMCRYPT_LIB_PATH environment variable not set, for more information please see: https://github.com/microsoft/rust-symcrypt/tree/main/rust-symcrypt#quick-start-guide"));
        println!("cargo:rustc-link-search=native={}", lib_path);

        //println!("cargo:rustc-link-lib=static=symcrypt");
        println!("cargo:rustc-link-lib=dylib=symcrypt");

        // During run time, the OS will handle finding the symcrypt.dll file. The places Windows will look will be:
        // 1. The folder from which the application loaded.
        // 2. The system folder. Use the GetSystemDirectory function to retrieve the path of this folder.
        // 3. The Windows folder. Use the GetWindowsDirectory function to get the path of this folder.
        // 4. The current folder.
        // 5. The directories that are listed in the PATH environment variable.

        // For more info please see: https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order

        // For the least invasive usage, we suggest putting the symcrypt.dll inside of same folder as the .exe file.

        // Note: This process is a band-aid. Long-term SymCrypt will be shipped with Windows which will make this process much more
        // streamlined.
    }

    #[cfg(target_os = "linux")]
    {
        // Note: Linux support is based off of the Azure Linux distro.
        // This has been tested on Ubuntu 22.04.03 LTS on WSL and has confirmed working but support for other distros
        // aside from Azure Linux is not guaranteed so YMMV.
        println!("cargo:rustc-link-lib=dylib=symcrypt"); // the "lib" prefix for libsymcrypt is implied on Linux

        // You must put the included symcrypt.so files in your usr/lib/x86_64-linux-gnu/ path.
        // This is where the Linux ld linker will look for the symcrypt.so files.

        // Note: This process is a band-aid. Long-term, our long term solution is to package manage SymCrypt for a subset of
        // Linux distros.
    }
     */

    Ok(())
}


fn compile_and_link_symcrypt() -> std::io::Result<()> {    // based on SymCrypt/lib/CMakeLists.txt
    println!("cargo:rerun-if-changed=upstream");
    println!("Compiling SymCrypt...");
    
    const LIB_NAME: &str = "symcrypt_static";
    compile_symcrypt_static(LIB_NAME)?;
    println!("cargo:rustc-link-lib=static={LIB_NAME}");
    
    Ok(())
}

fn compile_symcrypt_static(lib_name: &str) -> std::io::Result<()> {
    const SOURCE_DIR: &str = "upstream/lib";
    const COMMON_FILES: &[&str] = &[
        "env_generic.c", // symcrypt_generic
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
    const MODULE_FILES: &[&str] = &[
        #[cfg(windows)]
        "upstream/modules/windows/user/module.c",
    ];

    #[cfg(all(windows, target_arch = "x86_64"))]
    const ASM_FILES: &[&str] = &[
        "aesasm.asm",
        "fdef_asm.asm",
        "fdef_mulx.asm",
        "fdef369_asm.asm",
        "sha256xmm_asm.asm",
        "sha256ymm_asm.asm",
        "sha2common_asm.asm",
        "sha512ymm_asm.asm",
        "sha512ymm_avx512vl_asm.asm",
        "wipe.asm",
    ];

    let mut cc = cc::Build::new();
    cc.include("upstream/inc").warnings(false);
    for file in COMMON_FILES {
        cc.file(format!("{SOURCE_DIR}/{file}"));
    }
    cc.files(MODULE_FILES);

    #[cfg(all(windows, target_arch = "x86_64"))]
    cc.asm_flag("-Wa,-defsym,abc=1")
    .files(ASM_FILES);

    #[cfg(windows)]
    cc.file(format!("{SOURCE_DIR}/IEEE802_11SaeCustom.c"));
    #[cfg(all(not(windows), target_arch = "x86_64"))]
    cc.file(format!("{SOURCE_DIR}/linux/intrinsics.c"));

    println!("Files to compile: {}", cc.get_files().count());

    #[cfg(windows)]
    cc.define("SYMCRYPT_MASM", None);

    cc.compile(lib_name);

    Ok(())
}