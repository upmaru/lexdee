defmodule WebsocketServerMock do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    send_resp(conn, 200, "Hello from plug")
  end

  def start(pid) when is_pid(pid) do
    ref = make_ref()
    port = get_port()
    {:ok, agent_pid} = Agent.start_link(fn -> :ok end)
    url = "ws://localhost:#{port}/ws"

    opts = [dispatch: dispatch({pid, agent_pid}), port: port, ref: ref]

    case Plug.Adapters.Cowboy.http(__MODULE__, [], opts) do
      {:ok, _} ->
        {:ok, {ref, url}}

      {:error, :eaddrinuse} ->
        start(pid)
    end
  end

  def shutdown(ref) do
    Plug.Adapters.Cowboy.shutdown(ref)
  end

  def receive_socket_pid do
    receive do
      pid when is_pid(pid) -> pid
    after
      500 -> raise "No Server Socket pid"
    end
  end

  defp dispatch(tuple) do
    [{:_, [{"/ws", TestSocket, [tuple]}]}]
  end

  defp get_port do
    unless Process.whereis(__MODULE__), do: start_ports_agent()

    Agent.get_and_update(__MODULE__, fn port -> {port, port + 1} end)
  end

  defp start_ports_agent do
    Agent.start(fn -> Enum.random(50_000..63_000) end, name: __MODULE__)
  end
end

defmodule TestSocket do
  @behaviour :cowboy_websocket

  @impl :cowboy_websocket
  def init(req, [{test_pid, agent_pid}]) do
    case Agent.get(agent_pid, fn x -> x end) do
      :ok ->
        {:cowboy_websocket, req, [{test_pid, agent_pid}]}
    end
  end

  @impl :cowboy_websocket
  def terminate(_reason, _req, _state), do: :ok

  @impl :cowboy_websocket
  def websocket_init([{test_pid, agent_pid}]) do
    send(test_pid, self())
    {:ok, %{pid: test_pid, agent_pid: agent_pid}}
  end

  @impl :cowboy_websocket
  # If you are using other frame types, you will need to update the matching here.
  # Supported frames: See `InFrame` at https://ninenines.eu/docs/en/cowboy/2.5/manual/cowboy_websocket/
  def websocket_handle({:text, msg}, state) do
    send(state.pid, to_string(msg))
    handle_websocket_message(msg, state)
  end

  @impl :cowboy_websocket
  def websocket_info(:close, state), do: {:reply, :close, state}

  def websocket_info({:close, code, reason}, state) do
    {:reply, {:close, code, reason}, state}
  end

  def websocket_info({:send, frame}, state) do
    {:reply, frame, state}
  end

  # Hardcode commonly used expected frames and responses here
  # (This is just a convenience if you want to avoid having to respond to common frames from the test code)
  defp handle_websocket_message("{\"initiate_payment\": true}", state) do
    {:reply, {:text, Jason.encode!(%{payment_methods: ~w[credit_card apple]a})},
     state}
  end

  defp handle_websocket_message("another expected frame" <> _rest, state) do
    # no reply
    {:ok, state}
  end

  defp handle_websocket_message(_other, state), do: {:ok, state}
end
