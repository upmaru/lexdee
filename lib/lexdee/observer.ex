defmodule Lexdee.Observer do
  use GenServer

  require Logger
  require Mint.HTTP

  alias Lexdee.Observation

  @task Application.compile_env(:lexdee, :task) || Task

  defstruct [
    :conn,
    :feed,
    :base_uri,
    :resource,
    :url,
    :handler,
    :websocket,
    :request_ref,
    :caller,
    :status,
    :resp_headers,
    :closing?,
    :client_options,
    :last_pinged_at
  ]

  def start_link(options) do
    name = Keyword.get(options, :name)

    with {:ok, pid} <- GenServer.start_link(__MODULE__, options, name: name),
         {:ok, :connected} <- GenServer.call(pid, :connect) do
      {:ok, pid}
    end
  end

  @impl true
  def init(opts) do
    handler =
      Keyword.get(opts, :handler) ||
        Keyword.get(Application.get_env(:lexdee, __MODULE__), :handler)

    client = Keyword.fetch!(opts, :client)
    resource = Keyword.get(opts, :resource)
    type = Keyword.get(opts, :type, "operation")

    %{adapter: {_, _, options}, pre: middlewares} = client

    {_, _, [base_url]} =
      Enum.find(middlewares, fn {k, _, _v} ->
        k == Tesla.Middleware.BaseUrl
      end)

    base_uri = URI.parse(base_url)

    websocket_url =
      Keyword.get(opts, :url) ||
        "wss://#{base_uri.host}:#{base_uri.port}/1.0/events?type=#{type}"

    options =
      options
      |> List.flatten()
      |> Keyword.put(:protocols, [:http1])

    Process.send_after(self(), :check_connectivity, 15_000)

    state = %__MODULE__{
      resource: resource,
      client_options: options,
      handler: handler,
      url: websocket_url,
      feed: type,
      last_pinged_at: Keyword.get(opts, :last_pinged_at)
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:connect, from, state) do
    uri = URI.parse(state.url)

    http_scheme =
      case uri.scheme do
        "ws" -> :http
        "wss" -> :https
      end

    ws_scheme =
      case uri.scheme do
        "ws" -> :ws
        "wss" -> :wss
      end

    path =
      case uri.query do
        nil -> uri.path
        query -> uri.path <> "?" <> query
      end

    @task.async(fn ->
      %{
        "feed" => state.feed,
        "type" => "connection",
        "state" => "connecting"
      }
      |> Observation.new(state.resource)
      |> state.handler.handle_event()
    end)

    with {:ok, conn} <-
           Mint.HTTP.connect(
             http_scheme,
             uri.host,
             uri.port,
             state.client_options
           ),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(ws_scheme, conn, path, []) do
      state = %{state | conn: conn, request_ref: ref, caller: from}
      {:noreply, state}
    else
      {:error, %Mint.TransportError{reason: _reason} = reason} ->
        @task.async(fn ->
          %{
            "feed" => state.feed,
            "type" => "connection",
            "state" => "failed"
          }
          |> Observation.new(state.resource)
          |> state.handler.handle_event()
        end)

        {:reply, {:error, reason}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}

      {:error, conn, reason} ->
        {:reply, {:error, reason}, put_in(state.conn, conn)}
    end
  end

  @impl true
  def handle_info(:check_connectivity, state) do
    timestamp = DateTime.to_unix(DateTime.utc_now())

    if state.last_pinged_at && timestamp - state.last_pinged_at > 11 do
      @task.async(fn ->
        %{
          "feed" => state.feed,
          "type" => "connection",
          "state" => "disconnected",
          "metadata" => %{
            "last_pinged_at" => state.last_pinged_at,
            "checked_at" => timestamp
          }
        }
        |> Observation.new(state.resource)
        |> state.handler.handle_event()
      end)
    end

    send_frame(state, {:pong, "ok"})

    Process.send_after(self(), :check_connectivity, 15_000)

    {:noreply, state}
  end

  def handle_info({ref, _}, state) when is_reference(ref) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    {:noreply, state}
  end

  def handle_info(message, state) do
    case Mint.WebSocket.stream(state.conn, message) do
      {:ok, conn, responses} ->
        state =
          put_in(state.conn, conn)
          |> handle_responses(responses)

        if state.closing?, do: do_close(state), else: {:noreply, state}

      {:error, conn, reason, _responses} ->
        state =
          put_in(state.conn, conn)
          |> reply({:error, reason})

        {:noreply, state}

      :unknown ->
        {:noreply, state}
    end
  end

  defp handle_responses(state, responses)

  defp handle_responses(%{request_ref: ref} = state, [
         {:status, ref, status} | rest
       ]) do
    put_in(state.status, status)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [
         {:headers, ref, resp_headers} | rest
       ]) do
    put_in(state.resp_headers, resp_headers)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [{:done, ref} | rest]) do
    case Mint.WebSocket.new(state.conn, ref, state.status, state.resp_headers) do
      {:ok, conn, websocket} ->
        @task.async(fn ->
          %{
            "feed" => state.feed,
            "type" => "connection",
            "state" => "connected"
          }
          |> Observation.new(state.resource)
          |> state.handler.handle_event()
        end)

        %{
          state
          | conn: conn,
            websocket: websocket,
            status: nil,
            resp_headers: nil
        }
        |> reply({:ok, :connected})
        |> handle_responses(rest)

      {:error, conn, reason} ->
        put_in(state.conn, conn)
        |> reply({:error, reason})
    end
  end

  defp handle_responses(%{request_ref: ref, websocket: websocket} = state, [
         {:data, ref, data} | rest
       ])
       when websocket != nil do
    case Mint.WebSocket.decode(websocket, data) do
      {:ok, websocket, frames} ->
        put_in(state.websocket, websocket)
        |> handle_frames(frames)
        |> handle_responses(rest)

      {:error, websocket, reason} ->
        put_in(state.websocket, websocket)
        |> reply({:error, reason})
    end
  end

  defp handle_responses(state, [_response | rest]) do
    handle_responses(state, rest)
  end

  defp handle_responses(state, []), do: state

  defp send_frame(state, frame) do
    with {:ok, websocket, data} <-
           Mint.WebSocket.encode(state.websocket, frame),
         state = put_in(state.websocket, websocket),
         {:ok, conn} <-
           Mint.WebSocket.stream_request_body(
             state.conn,
             state.request_ref,
             data
           ) do
      {:ok, put_in(state.conn, conn)}
    else
      {:error, %Mint.WebSocket{} = websocket, reason} ->
        {:error, put_in(state.websocket, websocket), reason}

      {:error, conn, reason} ->
        {:error, put_in(state.conn, conn), reason}
    end
  end

  defp handle_frames(state, frames) do
    Enum.reduce(frames, state, fn
      # reply to pings with pongs
      {:ping, data}, state ->
        @task.async(fn ->
          %{"feed" => state.feed, "type" => "ping", "state" => data}
          |> Observation.new(state.resource)
          |> state.handler.handle_event()
        end)

        timestamp = DateTime.to_unix(DateTime.utc_now())

        state = put_in(state.last_pinged_at, timestamp)

        {:ok, state} = send_frame(state, {:pong, "ok"})
        state

      {:close, _code, reason}, state ->
        Logger.debug("Closing connection: #{inspect(reason)}")
        %{state | closing?: true}

      {:text, text}, state ->
        @task.async(fn ->
          text
          |> Jason.decode!()
          |> Map.merge(%{"feed" => state.feed})
          |> Observation.new(state.resource)
          |> state.handler.handle_event()
        end)

        {:ok, state} = send_frame(state, {:pong, "ok"})
        state

      frame, state ->
        Logger.debug("Unexpected frame received: #{inspect(frame)}")
        state
    end)
  end

  defp do_close(state) do
    # Streaming a close frame may fail if the server has already closed
    # for writing.
    _ = send_frame(state, :close)
    Mint.HTTP.close(state.conn)
    {:stop, :normal, state}
  end

  defp reply(state, response) do
    if state.caller, do: GenServer.reply(state.caller, response)
    put_in(state.caller, nil)
  end
end
