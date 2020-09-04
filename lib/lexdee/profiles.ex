defmodule Lexdee.Profiles do
  use Tesla

  @path "/1.0/profiles"

  def index(client), do: Tesla.get(client, @path)

  def create(client, params, opts \\ []),
    do: post(client, @path, params, opts)
end
