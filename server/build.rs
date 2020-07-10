fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("cargo:rustc-env=RUST_LOG=info");
    tonic_build::configure()
        .build_server(true)
        .out_dir("src")
        .compile(&["../proto/hub.proto"], &["../proto"])?;
    Ok(())
}
