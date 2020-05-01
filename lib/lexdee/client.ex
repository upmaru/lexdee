defmodule Lexdee.Client do
  alias X509.{
    Certificate,
    PrivateKey
  }

  def new(base_url, cert \\ nil, key \\ nil) do
    middleware = [
      Lexdee.Response,
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON
    ]

    adapter =
      {Tesla.Adapter.Mint,
       transport_opts: [
         verify: :verify_none,
         cert: build_cert(cert || File.read!(cert_path())),
         key: build_key(key || File.read!(key_path()))
       ]}

    Tesla.client(middleware, adapter)
  end

  defp build_key(key) do
    key = PrivateKey.from_pem!(key)

    type = elem(key, 0)

    {type, PrivateKey.to_der(key)}
  end

  defp build_cert(cert) do
    cert
    |> Certificate.from_pem!()
    |> Certificate.to_der()
  end

  defp cert_path,
    do:
      Application.get_env(:lexdee, :cert_path) ||
        Path.expand("~/.config/lxc/client.crt")

  defp key_path,
    do:
      Application.get_env(:lexdee, :key_path) ||
        Path.expand("~/.config/lxc/client.key")
end
