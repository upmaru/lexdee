defmodule Lexdee.Instances.StateTest do
  use ExUnit.Case

  describe "can start instance" do
    setup do
      id = "test-0012"

      response =
        File.read!(
          "test/support/fixtures/responses/instances/state/start/success.json"
        )

      bypass = Bypass.open()

      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, id: id, client: client, bypass: bypass, response: response}
    end

    test "return success when starting instance", %{
      bypass: bypass,
      client: client,
      response: response,
      id: id
    } do
      Bypass.expect(bypass, "PUT", "/1.0/instances/#{id}/state", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(202, response)
      end)

      assert {:ok, response} = Lexdee.start_instance(client, id)
    end
  end
end
