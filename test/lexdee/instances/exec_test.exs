defmodule Lexdee.Instances.ExecTest do
  use ExUnit.Case

  setup do
    id = "test-0012"

    bypass = Bypass.open()

    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, client: client, bypass: bypass, id: id}
  end

  describe "create command execution" do
    test "can execute a command", %{bypass: bypass, client: client, id: id} do
      response =
        File.read!(
          "test/support/fixtures/responses/instances/exec/success.json"
        )

      Bypass.expect(bypass, "POST", "/1.0/instances/#{id}/exec", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(202, response)
      end)

      assert {:ok, _data} = Lexdee.execute_command(client, id, ["echo 'blah'"])
    end
  end
end
