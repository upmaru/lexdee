defmodule Lexdee.Projects do
  use Tesla

  @path "/1.0/projects"

  def index(client, options \\ []), do: Tesla.get(client, @path, options)

  def show(client, id),
    do: get(client, Path.join(@path, id))

  def create(client, params, opts \\ []),
    do: post(client, @path, params, opts)

  def update(client, id, params, opts \\ []),
    do: patch(client, Path.join(@path, id), params, opts)
end
