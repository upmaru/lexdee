defmodule Lexdee.Certificates do
  @path "/1.0/certificates"

  def show(client, id), do: Tesla.get(client, id)
  def index(client), do: Tesla.get(client, @path)

  def create(client, params) do
    params =
      Map.merge(params, %{
        "certificate" => Base.encode64(Map.fetch!(params, "certificate")),
        "type" => "client"
      })

    Tesla.post(client, @path, params)
  end

  def update(client, id, params),
    do: Tesla.patch(client, id, params)
end
