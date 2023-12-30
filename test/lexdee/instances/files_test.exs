defmodule Lexdee.Instances.FilesTest do
  use ExUnit.Case

  setup do
    id = "test-02"

    bypass = Bypass.open()

    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, client: client, bypass: bypass, id: id}
  end

  describe "create file" do
    test "can create file", %{bypass: bypass, client: client, id: id} do
      response =
        File.read!(
          "test/support/fixtures/responses/instances/files/create.json"
        )

      Bypass.expect(bypass, "POST", "/1.0/instances/#{id}/files", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: %{}}} =
               Lexdee.create_file(client, id, "/root/example.json", "test",
                 query: [project: "default"]
               )
    end
  end
end
