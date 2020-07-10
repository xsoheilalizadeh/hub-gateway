using System;
using System.Threading.Tasks;
using Grpc.Core;
using Grpc.Net.Client;
using static Hub.Hub;

namespace Hub.Client
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // https://github.com/grpc/grpc-dotnet/issues/626
            AppContext.SetSwitch("System.Net.Http.SocketsHttpHandler.Http2UnencryptedSupport", true);

            using var channel = GrpcChannel.ForAddress("http://localhost:60011");

            var client = new HubClient(channel);

            while (true)
            {
                await Listen(client);
            }
        }

        private static async Task Listen(HubClient client)
        {
            Console.Write("\nEnter command: ");
            var command = Console.ReadLine();

            if (command == "get")
            {
                var request = new GatewayRequest();

                try
                {
                    var response = await client.GetGatewayAsync(request);
                    Console.WriteLine($"Redirect to {response.RedirectUrl}");
                }
                catch (RpcException e)
                {
                    Console.WriteLine(e.Message);

                    await Listen(client);
                }

            }
            else
            {
                Console.WriteLine($"'{command}' is invalid command!");

                await Listen(client);
            }
        }
    }
}
