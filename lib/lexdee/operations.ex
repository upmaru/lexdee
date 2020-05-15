defmodule Lexdee.Operations do
  @path "/1.0/operations"

  def index(client), do: Tesla.get(client, @path)
  def show(client, id), do: Tesla.get(client, id)
end