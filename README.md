## Hub Gateway 🗼

This is a sample for service communication with gRPC.

* [Client][client]: .NET 5 console application as gRPC client
* [Server][server]: Rust gRPC server


### How it works?

#### Server

```
cd .\server
cargo run
```

#### Client
```
cd .\client
dotnet run
```

### Usage
Enter `get` command in client it gives you the first success gateway from the server.

```
Enter command: get    
Redirect to https://google.com 
```

[client]:
[server]:
