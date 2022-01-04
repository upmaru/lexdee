defmodule Lexdee.Networks.Leases do
  use Tesla
  alias Lexdee.Networks

  @path "/leases"

  @spec list(Tesla.Client.t(), binary(), Keyword.t()) ::
         {:error, any} | {:ok, Tesla.Env.t()}
  def list(client, id, opts \\ []) do
    path =
      [Networks.base_path(), id, @path]
      |> Path.join()

    get(client, path, opts)
  end
end
