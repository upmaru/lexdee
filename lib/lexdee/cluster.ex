defmodule Lexdee.Cluster do
  @path "/1.0/cluster"

  def show(client), do: Tesla.get(client, @path)

  def update(client, params),
    do: Tesla.put(client, @path, params)
end
