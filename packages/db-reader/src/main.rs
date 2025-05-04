use axum::{
    routing::get,
    Router,
    response::IntoResponse,
    serve,
};
use std::env;
use std::net::SocketAddr;
use tokio_postgres::NoTls;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();

    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <port>", args[0]);
        std::process::exit(1);
    }

    let port: u16 = args[1].parse().expect("Invalid port number");

    let app = Router::new().route("/", get(handler));

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("Listening on {}", addr);

    serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app.into_make_service())
        .await
        .unwrap();

}

async fn handler() -> impl IntoResponse {
    let conn_str = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set in the environment");

    let (client, connection) =
        tokio_postgres::connect(&conn_str, NoTls).await.unwrap();

    // Spawn connection handler
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    let rows = client
        .query("SELECT content, date FROM testcounter ORDER BY id desc", &[])
        .await
        .unwrap();

    let mut output = String::new();

    for row in rows {
        let content: String = row.get("content");
        let date: chrono::NaiveDateTime = row.get("date");
        output.push_str(&format!("{}: {}\n", date.format("%Y-%m-%d %H:%M:%S"), content));
    }

    output
}
