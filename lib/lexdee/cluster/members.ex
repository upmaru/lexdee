defmodule Lexdee.Cluster.Members do
  @path "/1.0/cluster/members"

  use Lexdee.Utils

  def index(client), do: Tesla.get(client, @path)
  def show(client, id), do: Tesla.get(client, get_id(id))
end
