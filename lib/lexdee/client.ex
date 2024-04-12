defmodule Lexdee.Client do
  alias X509.{
    Certificate,
    PrivateKey
  }

  def new(base_url, cert \\ nil, key \\ nil, options \\ []) do
    middleware = [
      Lexdee.Response,
      {Tesla.Middleware.BaseUrl, base_url},
      Tesla.Middleware.JSON
    ]

    adapter = get_adapter(cert, key, options)

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

  defp get_adapter(cert, key, options) do
    if Application.get_env(:lexdee, :environment) == :test do
      {Tesla.Adapter.Mint, []}
    else
      timeout = Keyword.get(options, :timeout, 30_000)

      {Tesla.Adapter.Mint,
       timeout: timeout,
       transport_opts: [
         verify: :verify_none,
         cert: build_cert(cert || File.read!(cert_path())),
         key: build_key(key || File.read!(key_path()))
       ]}
    end
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
