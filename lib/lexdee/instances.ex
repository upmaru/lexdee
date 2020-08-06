defmodule Lexdee.Instances do
  use Telsa

  @path "/1.0/instances"

  def index(client), do: Tesla.get(client, @path)
  def show(client, id), do: Tesla.get(client, id)

  def create(client, params, opts \\ []),
    do: post(client, @path, params, opts)
end
