defmodule Lexdee.Events do
  use Tesla

  @path "/1.0/events"

  @spec index(Tesla.Client.t(), Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def index(client, opts \\ [query: [type: "operation"]]),
    do: Tesla.get(client, @path, opts)
end
