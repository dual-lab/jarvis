#[cfg(not(feature = "bin"))]
compile_error!("binary cargo-kbuild can not be compiled without bin feature. Add command '--feature bin'");

fn main() {
    println!("Kbuild is here to help you");
}
