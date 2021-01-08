defmodule Lexdee.InstancesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()

    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, client: client, bypass: bypass}
  end

  describe "create instance" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/instances/create.json")

      {:ok, response: response}
    end

    test "return success for create instance", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(
        bypass,
        "POST",
        "/1.0/instances",
        fn conn ->
          assert conn.query_string == "target=lxd-experiment"

          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(202, response)
        end
      )

      assert {:ok, data} =
               Lexdee.create_instance(
                 client,
                 %{
                   "name" => "test-02",
                   "architecture" => "x86_64",
                   "ephemeral" => false,
                   "profiles" => ["default"],
                   "source" => %{
                     "type" => "image",
                     "mode" => "pull",
                     "protocol" => "simplestreams",
                     "server" => "https://images.linuxcontainers.org",
                     "alias" => "alpine/3.11"
                   }
                 },
                 query: [target: "lxd-experiment"]
               )
    end
  end

  describe "delete instance" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/instances/delete.json")

      {:ok, response: response}
    end

    test "return success for delete instance", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(
        bypass,
        "DELETE",
        "/1.0/instances/test-0012",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(202, response)
        end
      )

      assert {:ok, data} = Lexdee.delete_instance(client, "test-0012")
    end
  end
end
