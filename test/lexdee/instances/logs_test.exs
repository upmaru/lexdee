defmodule Lexdee.Instances.LogsTest do
  use ExUnit.Case

  setup do
    id = "test-0012"

    file_name = "exec_50518d94-a159-4710-bb19-3a401dc6f163.stdout"

    bypass = Bypass.open()

    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, id: id, file_name: file_name, bypass: bypass, client: client}
  end

  describe "can return result from log" do
    test "successfully return log data", %{
      bypass: bypass,
      client: client,
      file_name: file_name,
      id: id
    } do
      response =
        File.read!("test/support/fixtures/responses/instances/logs/show.txt")

      Bypass.expect(
        bypass,
        "GET",
        "/1.0/instances/#{id}/logs/#{file_name}",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_header(
            "content-disposition",
            "inline;filename=#{file_name}"
          )
          |> Plug.Conn.put_resp_header(
            "content-type",
            "application/octet-stream"
          )
          |> Plug.Conn.resp(200, response)
        end
      )

      assert {:ok, log_data} = Lexdee.show_instance_log(client, id, file_name)
    end
  end
end
