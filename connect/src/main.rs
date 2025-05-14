#[tokio::main]
async fn main() {
    println!("Make me faster!");
    let ip = reqwest::get("https://ipinfo.io/ip")
        .await.unwrap()
        .text()
        .await.unwrap();
     
    println!("IP  = {ip:?} ");
}
