defmodule Lexdee.ImagesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()

    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, client: client, bypass: bypass}
  end

  describe "delete image" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/images/delete.json")

      {:ok, response: response}
    end

    test "return success for deleting image", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "DELETE", "/1.0/images/somefingerprint", fn conn ->
        assert conn.query_string == "project=something"

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, _data} =
               Lexdee.delete_image(client, "somefingerprint",
                 query: [project: "something"]
               )
    end
  end
end
