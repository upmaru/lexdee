defmodule Lexdee.Cluster.Members do
  @path "/1.0/cluster/members"

  def index(client), do: Tesla.get(client, @path)
  def show(client, id), do: Tesla.get(client, id)
end
