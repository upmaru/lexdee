defmodule Lexdee.Operations do
  @path "/1.0/operations"

  def show(client, id), do: Tesla.get(client, Path.join(@path, id))
end
