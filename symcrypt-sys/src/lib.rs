#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(clippy::all)]

extern crate libc;

mod symcrypt_bindings;
pub use symcrypt_bindings::*;

static SYMCRYPT_LIB: std::sync::LazyLock<SymCryptLib> = std::sync::LazyLock::new(|| {
    unsafe{ SymCryptLib::new("symcrypt.dll") }.expect("failed to load symcrypt.dll")
});

pub fn symcrypt_lib() -> &'static SymCryptLib {
    &SYMCRYPT_LIB
}