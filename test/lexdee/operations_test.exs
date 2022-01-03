defmodule Lexdee.OperationsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, bypass: bypass, client: client}
  end

  describe "wait for operation" do
    test "successfully return operation result", %{
      bypass: bypass,
      client: client
    } do
      id = "8839664a-c4be-4e9f-978e-78d858635817"

      response =
        File.read!("test/support/fixtures/responses/operations/wait.json")

      Bypass.expect(
        bypass,
        "GET",
        "/1.0/operations/#{id}/wait",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_header("content-type", "application/json")
          |> Plug.Conn.resp(200, response)
        end
      )

      assert {:ok, _result} =
               Lexdee.wait_for_operation(client, id, query: [timeout: 60])
    end
  end
end
