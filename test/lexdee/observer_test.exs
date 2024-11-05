defmodule Lexdee.ObserverTest do
  use ExUnit.Case

  setup do
    {:ok, {server_ref, url}} = WebsocketServerMock.start(self())
    on_exit(fn -> WebsocketServerMock.shutdown(server_ref) end)

    uri = URI.parse(url)

    client = Lexdee.create_client("http://localhost:#{uri.port}")

    {:ok, url: url, client: client, server_ref: server_ref}
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
    defmodule PingHandler do
      def handle_event(%Lexdee.Observation{type: "connection"} = observation) do
        assert observation.event.object.body in ["connected", "connecting"]
      end

      def handle_event(%Lexdee.Observation{type: "ping"} = observation) do
        assert observation.event.object.body == "keepalive"
      end
    end

    test "can receive ping", %{url: url, client: client} do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: PingHandler
               )

      Lexdee.Observer.connect(pid)

      server_pid = WebsocketServerMock.receive_socket_pid()

      send(server_pid, {:send, {:ping, "keepalive"}})

      assert_receive "ok"
    end

    test "no disconnection", %{url: url, client: client} do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: PingHandler
               )

      Lexdee.Observer.connect(pid)

      send(pid, :check_connectivity)

      assert_receive "ok"
    end
  end

  describe "check connectivity" do
    defmodule ConnectivityHandler do
      def handle_event(%Lexdee.Observation{type: "connection"} = observation) do
        assert observation.event.object.body in [
                 "connected",
                 "connecting",
                 "disconnected"
               ]

        if observation.event.object.body == "disconnected" do
          assert %{"last_pinged_at" => _timestamp} =
                   observation.event.object.metadata
        end
      end

      def handle_event(%Lexdee.Observation{type: "ping"} = observation) do
        assert observation.event.object.body == "keepalive"
      end
    end

    test "can check connectivity", %{
      url: url,
      client: client,
      server_ref: server_ref
    } do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: ConnectivityHandler,
                 parent: self()
               )

      {:ok, _state} = Lexdee.Observer.connect(pid)

      WebsocketServerMock.shutdown(server_ref)

      send(pid, :check_connectivity)

      assert_receive :closed
    end
  end

  describe "text" do
    defmodule TextHandler do
      def handle_event(%Lexdee.Observation{type: "connection"} = observation) do
        assert observation.event.object.body in ["connected", "connecting"]
      end

      def handle_event(%Lexdee.Observation{type: "lifecycle"} = observation) do
        assert %Lexdee.Observation{} = observation
        assert %Lexdee.Lifecycle{action: action} = observation.event.object
        assert "instance-started" == action
      end

      def handle_event(%Lexdee.Observation{
            type: "operation",
            event: %Lexdee.Event{object: %{class: "websocket"} = object}
          }) do
        assert %Lexdee.Operation{} = object
        assert %Lexdee.Websocket{} = object.metadata
      end

      def handle_event(%Lexdee.Observation{
            type: "operation",
            event: %Lexdee.Event{object: %{class: "task"} = object}
          }) do
        assert %Lexdee.Operation{} = object
      end
    end

    test "can receive task event", %{url: url, client: client} do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: TextHandler
               )

      Lexdee.Observer.connect(pid)

      server_pid = WebsocketServerMock.receive_socket_pid()

      payload = File.read!("test/support/fixtures/websocket/task.json")

      send(server_pid, {:send, {:text, payload}})

      assert_receive "ok"
    end

    test "can receive websocket", %{url: url, client: client} do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: TextHandler
               )

      {:ok, _state} = Lexdee.Observer.connect(pid)

      server_pid = WebsocketServerMock.receive_socket_pid()

      payload = File.read!("test/support/fixtures/websocket/websocket.json")
      send(server_pid, {:send, {:text, payload}})

      assert_receive "ok"
    end

    test "can receive lifecycle", %{url: url, client: client} do
      assert {:ok, pid} =
               Lexdee.Observer.start_link(
                 url: url,
                 client: client,
                 handler: TextHandler
               )

      {:ok, _state} = Lexdee.Observer.connect(pid)

      server_pid = WebsocketServerMock.receive_socket_pid()

      payload = File.read!("test/support/fixtures/websocket/lifecycle.json")
      send(server_pid, {:send, {:text, payload}})

      assert_receive "ok"
    end
  end
end
