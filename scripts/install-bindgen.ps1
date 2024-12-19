if ($env:OS -eq "Windows_NT") {
    winget install LLVM.LLVM
} else {
    sudo apt install libclang-dev
}
cargo install bindgen-cli