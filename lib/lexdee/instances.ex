defmodule Lexdee.Instances do
  @path "/1.0/instances"

  def index(client), do: Tesla.get(client, @path)
  def show(client, id), do: Tesla.get(client, id)

  def create(client, params) do
    Tesla.post(client, @path, params)
  end
end
