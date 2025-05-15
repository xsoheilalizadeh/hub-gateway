
#[tokio::main]
async fn main() {
    println!("Make me faster!");
    let ip = reqwest::get("https://ipinfo.io/ip")
        .await.unwrap()
        .text()
        .await.unwrap();
    
   let a = common::add(112, 1213221222223);
    
    println!("Connect IPcc  = {ip:?} {a:?}");
}
