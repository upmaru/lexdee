defmodule Lexdee.Operations do
  @path "/1.0/operations"

  def index(client), do: Tesla.get(client, @path)

  def wait(client, id, opts \\ []),
    do: Tesla.get(client, Path.join([@path, id, "wait"]), opts)

  def show(client, id), do: Tesla.get(client, id)
end
