defmodule Lexdee.Certificates do
  @path "/1.0/certificates"

  def show(client, id), do: Tesla.get(client, id)
  def index(client), do: Tesla.get(client, @path)

  def create(client, params) do
    certificate =
      Map.fetch!(params, "certificate")
      |> X509.Certificate.from_pem!()
      |> X509.Certificate.to_der()
      |> Base.encode64()

    params =
      Map.merge(params, %{
        "certificate" => certificate,
        "type" => "client"
      })

    Tesla.post(client, @path, params)
  end

  def update(client, id, params),
    do: Tesla.patch(client, id, params)
end
