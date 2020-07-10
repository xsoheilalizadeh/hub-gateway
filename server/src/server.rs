mod hub;

use hyper_tls::HttpsConnector;
use {futures::future::*, hub::*, hyper, tonic::transport::Server};

#[macro_use]
extern crate log;

#[derive(Debug, Default)]
struct Hub {}

#[tonic::async_trait]
impl hub_server::Hub for Hub {
    async fn get_gateway(
        &self,
        _request: tonic::Request<GatewayRequest>,
    ) -> Result<tonic::Response<GatewayResponse>, tonic::Status> {
        let gateways = [
            "https://stackoverflow.com/",
            "https://google.com",
            "https://bing.com",
            "https://twitter.com",
        ];

        let requests = gateways.iter().map(|url| get_redirect_url(url).boxed());

        let redirect_url = select_ok(requests).await.unwrap().0.to_string();

        let response = GatewayResponse { redirect_url };

        Ok(tonic::Response::new(response))
    }
}

async fn get_redirect_url(gateway_uri: &'static str) -> Result<&'static str, ()> {
    let url = &hyper::http::Uri::from_static(gateway_uri);

    let https = HttpsConnector::new();
    let client = hyper::Client::builder().build::<_, hyper::Body>(https);

    info!("GET {}", url);

    let response = client.get(url.clone()).await.unwrap();

    info!("{} - {}", url, response.status());

    Ok(gateway_uri)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();

    let addr = "[::1]:60011".parse()?;

    info!("Hub Server listening on {}", addr);

    let hub = Hub::default();

    Server::builder()
        .add_service(hub_server::HubServer::new(hub))
        .serve(addr)
        .await
        .unwrap();

    Ok(())
}
