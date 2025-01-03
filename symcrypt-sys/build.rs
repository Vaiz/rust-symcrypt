fn main() -> std::io::Result<()> {
    #[cfg(feature = "dynamic")]
    link_symcrypt_dynamicaly()?;

    #[cfg(not(feature = "dynamic"))]
    static_link::compile_and_link_symcrypt()?;

    Ok(())
}

#[cfg(feature = "dynamic")]
fn link_symcrypt_dynamicaly() -> std::io::Result<()> {
    #[cfg(target_os = "windows")]
    {
        // Look for the .lib file during link time. We are searching the Windows/System32 path which is set as a current default to match
        // the long term placement of a Windows shipped symcrypt.dll

        let lib_path = std::env::var("SYMCRYPT_LIB_PATH")
            .unwrap_or_else(|_| panic!("SYMCRYPT_LIB_PATH environment variable not set, for more information please see: https://github.com/microsoft/rust-symcrypt/tree/main/rust-symcrypt#quick-start-guide"));
        println!("cargo:rustc-link-search=native={}", lib_path);

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

    Ok(())
}

#[cfg(not(feature = "dynamic"))]
pub mod static_link {
    pub fn compile_and_link_symcrypt() -> std::io::Result<()> {
        // based on SymCrypt/lib/CMakeLists.txt

        let target_triple = Triple::get_target_triple();
        println!("Target triple: {}", target_triple.to_triple());

        const ADDITIONAL_DEPENDENCIES: &[&str] = &[
            #[cfg(windows)]
            "bcrypt",
        ];
        println!("cargo:rerun-if-changed=upstream");
        println!("Compiling SymCrypt...");

        const LIB_NAME: &str = "symcrypt_static";
        compile_symcrypt_static(LIB_NAME, target_triple)?;
        println!("cargo:rustc-link-lib=static={LIB_NAME}");

        for dep in ADDITIONAL_DEPENDENCIES {
            println!("cargo:rustc-link-lib=dylib={dep}");
        }

        Ok(())
    }

    #[allow(non_camel_case_types)]
    #[derive(Debug, PartialEq, Eq)]
    enum Triple {
        x86_64_pc_windows_msvc,
        aarch64_pc_windows_msvc,
        x86_64_unknown_linux_gnu,
        aarch64_unknown_linux_gnu,
    }

    impl Triple {
        fn get_target_triple() -> Self {
            let target_os = std::env::var("CARGO_CFG_TARGET_OS").unwrap();
            let target_arch = std::env::var("CARGO_CFG_TARGET_ARCH").unwrap();

            match (target_os.as_str(), target_arch.as_str()) {
                ("windows", "x86_64") => Triple::x86_64_pc_windows_msvc,
                ("windows", "aarch64") => Triple::aarch64_pc_windows_msvc,
                ("linux", "x86_64") => Triple::x86_64_unknown_linux_gnu,
                ("linux", "aarch64") => Triple::aarch64_unknown_linux_gnu,
                _ => panic!("unsupported target. OS: {target_os}, Arch: {target_arch}"),
            }
        }
        fn is_windows(&self) -> bool {
            matches!(
                self,
                Triple::x86_64_pc_windows_msvc | Triple::aarch64_pc_windows_msvc
            )
        }
        fn to_triple(&self) -> &'static str {
            match self {
                Triple::x86_64_pc_windows_msvc => "x86_64-pc-windows-msvc",
                Triple::aarch64_pc_windows_msvc => "aarch64-pc-windows-msvc",
                Triple::x86_64_unknown_linux_gnu => "x86_64-unknown-linux-gnu",
                Triple::aarch64_unknown_linux_gnu => "aarch64-unknown-linux-gnu",
            }
        }
    }

    const SOURCE_DIR: &str = "upstream/lib";
    const CMAKE_SOURCES_COMMON: &str = "
3des.c
a_dispatch.c
aes-asm.c
aes-c.c
aes-default-bc.c
aes-default.c
aes-key.c
aes-neon.c
aes-selftest.c
aes-xmm.c
aes-ymm.c
aescmac.c
aesCtrDrbg.c
AesTables.c
blockciphermodes.c
ccm.c
chacha20_poly1305.c
chacha20.c
cpuid_notry.c
cpuid_um.c
cpuid.c
crt.c
DesTables.c
desx.c
dh.c
dl_internal_groups.c
dlgroup.c
dlkey.c
dsa.c
ec_dh.c
ec_dispatch.c
ec_dsa.c
ec_internal_curves.c
ec_montgomery.c
ec_mul.c
ec_short_weierstrass.c
ec_twisted_edwards.c
eckey.c
ecpoint.c
ecurve.c
equal.c
FatalIntercept.c
fdef_general.c
fdef_int.c
fdef_mod.c
fdef369_mod.c
fips_selftest.c
gcm.c
gen_int.c
ghash.c
hash.c
hkdf_selftest.c
hkdf.c
hmac.c
hmacmd5.c
hmacsha1.c
hmacsha256.c
hmacsha384.c
hmacsha512.c
hmacsha3_256.c
hmacsha3_384.c
hmacsha3_512.c
kmac.c
libmain.c
marvin32.c
md2.c
md4.c
md5.c
modexp.c
paddingPkcs7.c
parhash.c
pbkdf2_hmacsha1.c
pbkdf2_hmacsha256.c
pbkdf2.c
poly1305.c
primes.c
rc2.c
rc4.c
rdrand.c
rdseed.c
recoding.c
rsa_enc.c
rsa_padding.c
rsakey.c
ScsTable.c
scsTools.c
selftest.c
session.c
sha1.c
sha256.c
sha256Par.c
sha256Par-ymm.c
sha256-xmm.c
sha256-ymm.c
sha512.c
sha512Par.c
sha512Par-ymm.c
sha512-ymm.c
sha3.c
sha3_256.c
sha3_384.c
sha3_512.c
shake.c
sp800_108_hmacsha1.c
sp800_108_hmacsha256.c
sp800_108_hmacsha512.c
sp800_108.c
srtp_kdf.c
srtp_kdf_selftest.c
ssh_kdf.c
ssh_kdf_sha256.c
ssh_kdf_sha512.c
tlsCbcVerify.c
tlsprf_selftest.c
tlsprf.c
xtsaes.c
";

    fn compile_symcrypt_static(lib_name: &str, triple: Triple) -> std::io::Result<()> {
        let mut other_files = vec![
            "env_generic.c", // symcrypt_generic
        ];
        let mut module_files = vec![];

        if triple.is_windows() {
            other_files.push("env_windowsUserModeWin7.c");
            other_files.push("env_windowsUserModeWin8_1.c");
            other_files.push("IEEE802_11SaeCustom.c");
            module_files.push("upstream/modules/windows/user/module.c");
        } else {
            other_files.push("linux/intrinsics.c");
        }

        let asm_files = match triple {
            Triple::x86_64_pc_windows_msvc => vec![
                "aesasm.asm",
                "fdef_asm.asm",
                "fdef_mulx.asm",
                "fdef369_asm.asm",
                "sha256xmm_asm.asm",
                "sha256ymm_asm.asm",
                "sha512ymm_asm.asm",
                "sha512ymm_avx512vl_asm.asm",
                "wipe.asm",
            ],
            Triple::aarch64_pc_windows_msvc => vec![
                "fdef_asm.asm",
                "fdef369_asm.asm",
                "wipe.asm",
            ],
            Triple::x86_64_unknown_linux_gnu => vec![
                "aesasm-gas.asm",
                "fdef_asm-gas.asm",
                "fdef369_asm-gas.asm",
                "fdef_mulx-gas.asm",
                "wipe-gas.asm",
                "sha256xmm_asm-gas.asm",
                "sha256ymm_asm-gas.asm",
                "sha512ymm_asm-gas.asm",
                "sha512ymm_avx512vl_asm-gas.asm",
            ],
            Triple::aarch64_unknown_linux_gnu => vec![
                "fdef_asm-gas.asm",
                "fdef369_asm-gas.asm",
                "wipe-gas.asm",
            ],
        };

        let mut cc = cc::Build::new();
        cc.target(&triple.to_triple())
            .include("upstream/inc")
            .warnings(false);

        for file in CMAKE_SOURCES_COMMON
            .lines()
            .filter(|line| !(line.trim().is_empty() || line.trim().starts_with("#")))
        {
            cc.file(format!("{SOURCE_DIR}/{}", file.trim()));
        }
        for file in other_files {
            cc.file(format!("{SOURCE_DIR}/{file}"));
        }
        for file in asm_files {
            cc.file(format!("{SOURCE_DIR}/asm/{}/{file}", triple.to_triple()));
        }
        cc.files(module_files);        

        if triple == Triple::x86_64_pc_windows_msvc {
            cc.asm_flag("/DSYMCRYPT_MASM");
        }
        if triple == Triple::aarch64_pc_windows_msvc {
            cc.define("_ARM64_", None);
        }

        println!("Files to compile: {}", cc.get_files().count());
        cc.compile(lib_name);

        Ok(())
    }
}
