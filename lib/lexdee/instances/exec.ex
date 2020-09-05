defmodule Lexdee.Instances.Exec do
  use Tesla
  alias Lexdee.Instances

  @path "/exec"

  @default_params %{
    "environment" => {},
    "wait-for-websocket" => false,
    "record-output" => true,
    "interactive" => false
  }

  @spec perform(Testla.Client.t(), list(String.t()), Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def perform(client, id, commands, opts \\ []) do
    params =
      @default_params
      |> Map.merge(%{
        "command" => commands
      })

    path =
      [Instances.base_path(), id, @path]
      |> Path.join()

    client
    |> post(path, params, opts)
  end
end
