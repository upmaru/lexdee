defmodule Lexdee.Instances.Exec do
  use Tesla
  alias Lexdee.Instances

  @path "/exec"

  @spec perform(Testla.Client.t(), list(String.t()), Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def perform(client, id, command, opts \\ []) do
    settings = Keyword.get(opts, :settings, %{})

    params = %{
      "command" => ["/bin/sh", "-c", command],
      "environment" => Map.get(settings, :environment, %{}),
      "wait-for-websocket" => Map.get(settings, :wait_for_websocket, false),
      "record-output" => Map.get(settings, :record_output, true),
      "interactive" => Map.get(settings, :interactive, false)
    }

    path =
      [Instances.base_path(), id, @path]
      |> Path.join()

    client
    |> post(path, params, opts)
  end
end
