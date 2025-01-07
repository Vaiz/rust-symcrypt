fn main() {
    println!("Hello, world!");

    println!("symcrypt_sys (0.6.0)::is_dynamic_link: {}", symcrypt_sys_06::is_dynamic_link());
    println!("symcrypt_sys (0.7.0)::is_dynamic_link: {}", symcrypt_sys_07::is_dynamic_link());

    test_random("symcrypt (0.4.0)", symcrypt_04::symcrypt_random);
    test_random("symcrypt (0.5.0)", symcrypt_05::symcrypt_random);
    test_random("symcrypt (0.6.0)", symcrypt_06::symcrypt_random);
    test_random("symcrypt (0.7.0)", symcrypt_07::symcrypt_random);
}

fn test_random(lib: &str, rnd_fn: fn(&mut [u8])) {
    let mut buf = [0u8; 16];
    rnd_fn(&mut buf);
    println!("{lib}: {:?}", buf);
}