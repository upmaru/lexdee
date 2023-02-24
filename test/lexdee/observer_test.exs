defmodule Lexdee.ObserverTest do
  use ExUnit.Case

  setup do
    {:ok, {server_ref, url}} = WebsocketServerMock.start(self())
    on_exit(fn -> WebsocketServerMock.shutdown(server_ref) end)

    uri = URI.parse(url)

    client = Lexdee.create_client("http://localhost:#{uri.port}")

    {:ok, url: url, client: client}
  end

  test "connect", %{url: url, client: client} do
    defmodule Handler do
      def handle_event(%Lexdee.Observation{type: "connection"} = observation) do
        assert observation.event.object.body in ["connected", "connecting"]
      end
    end

    assert {:ok, _pid} =
             Lexdee.Observer.start_link(
               url: url,
               client: client,
               handler: Handler
             )
  end
end
