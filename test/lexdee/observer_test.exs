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
    test "can receive ping", %{url: url, client: client} do
      defmodule PingHandler do
        def handle_event(%Lexdee.Observation{type: "ping"} = observation) do        
          IO.inspect(observation)
        
          assert observation.event.object.body == "keepalive"
        end
        
        def handle_event(observation) do              
          :ok
        end
      end
      
      
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: PingHandler
               )
               
      state = GenServer.call(pid, :state)
      
      {:ok, websocket, data} = Mint.WebSocket.encode(state.websocket, {:ping, "keepalive"})
      
      {:ok, conn} = Mint.WebSocket.stream_request_body(state.conn, state.request_ref, data)
      
      # TODO test this properly
    end
  end
end
