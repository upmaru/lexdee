defmodule Lexdee.CertificatesTest do
  use ExUnit.Case

  describe "create certificate" do
    setup do
      response = File.read!("test/support/fixtures/create_certificate.json")

      cert = File.read!("test/support/fixtures/cert/cert.pem")

      bypass = Bypass.open()

      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, client: client, bypass: bypass, response: response, cert: cert}
    end

    test "return success for create certificate", %{
      bypass: bypass,
      client: client,
      response: response,
      cert: cert
    } do
      Bypass.expect(bypass, "POST", "/1.0/certificates", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(201, response)
      end)

      assert {:ok, nil} =
               Lexdee.create_certificate(client, %{
                 "password" => "something",
                 "certificate" => cert
               })
    end
  end
end
