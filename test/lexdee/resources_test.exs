defmodule Lexdee.ResourcesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, bypass: bypass, client: client}
  end

  describe "query resources" do
    test "return success for resources", %{bypass: bypass, client: client} do
      response =
        File.read!("test/support/fixtures/responses/resources/show.json")

      Bypass.expect(bypass, "GET", "/1.0/resources", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      assert {:ok, %{body: body}} = Lexdee.show_resources(client)

      assert %{"memory" => _memory} = body
    end

    test "can query resources with target", %{bypass: bypass, client: client} do
      response =
        File.read!("test/support/fixtures/responses/resources/show.json")

      Bypass.expect(bypass, "GET", "/1.0/resources", fn conn ->
        assert %{"target" => "some-node-01"} = conn.params

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.send_resp(200, response)
      end)

      assert {:ok, %{body: body}} =
               Lexdee.show_resources(client, "some-node-01")

      assert %{"memory" => _memory} = body
    end
  end
end
