defmodule Lexdee.Instances.Logs do
  use Tesla

  alias Lexdee.Instances

  @path "/logs"

  @spec show(Tesla.Client.t(), binary, binary, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def show(client, instance, log_file, options \\ []) do
    path =
      [Instances.base_path(), instance, @path, log_file]
      |> Path.join()

    get(client, path, options)
  end
end
