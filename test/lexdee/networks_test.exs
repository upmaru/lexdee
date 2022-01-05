defmodule Lexdee.NetworksTest do
  use ExUnit.Case

  describe "list networks with recursive option" do
    setup do
      response =
        File.read!(
          "test/support/fixtures/responses/networks/index_recursive_one.json"
        )

      bypass = Bypass.open()

      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, bypass: bypass, response: response, client: client}
    end

    test "return list of networks", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "GET", "/1.0/networks", fn conn ->
        assert %{"recursive" => "1"} = conn.query_params

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: body}} =
               Lexdee.list_networks(client, query: [recursive: 1])

      assert %{"name" => "lxdfan0"} =
               Enum.find(body, fn network ->
                 network["managed"]
               end)
    end
  end
end
