#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(clippy::all)]

extern crate libc;

mod symcrypt_bindings;
pub use symcrypt_bindings::*;

static SYMCRYPT_DLL: once_cell::sync::OnceCell<symcrypt_bindings::symcrypt> =
    once_cell::sync::OnceCell::new();

pub fn load_symcrypt_lib(path: Option<&str>) -> Result<(), ::libloading::Error> {
    SYMCRYPT_DLL.get_or_try_init(move || {
        let path = path.unwrap_or("symcrypt.dll");
        unsafe { symcrypt_bindings::symcrypt::new(path) }
    }).map(|_| ())
}

pub fn symcrypt_lib() -> Option<&'static symcrypt_bindings::symcrypt> {
    SYMCRYPT_DLL.get()
}
