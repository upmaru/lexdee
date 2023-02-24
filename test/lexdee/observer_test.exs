defmodule Lexdee.ObserverTest do
  use ExUnit.Case

  setup do
    {:ok, {server_ref, url}} = WebsocketServerMock.start(self())
    on_exit(fn -> WebsocketServerMock.shutdown(server_ref) end)
    
    uri = URI.parse(url)

    client = Lexdee.create_client("http://localhost:#{uri.port}")

    {:ok, url: url, client: client}
  end
  
  describe "connect" do
    test "can connect", %{url: url, client: client} do
      defmodule ConnectHandler do
        def handle_event(%Lexdee.Observation{type: "connection"} = observation) do
          assert observation.event.object.body in ["connected", "connecting"]
        end
      end
  
      assert {:ok, _pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: ConnectHandler
               )
    end
  end
  
  describe "ping" do
    test "ping", %{url: url, client: client} do
      defmodule PingHandler do
        def handle_event(%Lexdee.Observation{type: "ping"} = observation) do        
          assert observation.event.object.body == "keepalive"
        end
        
        def handle_event(observation) do      
          IO.inspect(observation)
              
          :ok
        end
      end
      
      
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: PingHandler
               )
                             
      send(pid, "soemthing")
    end
  end
end
