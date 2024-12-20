#[cfg(all(target_os = "windows", target_arch = "x86_64"))]
pub(crate) mod x86_64_pc_windows_msvc;

#[cfg(all(target_os = "windows", target_arch = "x86_64"))]
pub(crate) use x86_64_pc_windows_msvc::*;
