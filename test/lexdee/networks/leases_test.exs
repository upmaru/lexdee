defmodule Lexdee.Networks.LeasesTest do
  use ExUnit.Case

  describe "list network leases" do
    setup do
      response =
        File.read!(
          "test/support/fixtures/responses/networks/leases/success.json"
        )

      bypass = Bypass.open()

      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, client: client, bypass: bypass, response: response}
    end

    test "return list of leases", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "GET", "/1.0/networks/lxdfan0/leases", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: body}} = Lexdee.list_network_leases(client, "lxdfan0")
      assert Enum.count(body) == 2
    end
  end
end
