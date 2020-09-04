defmodule Lexdee.Cluster.MembersTest do
  use ExUnit.Case

  describe "show member" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/cluster/member/show.json")

      bypass = Bypass.open()
      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, client: client, bypass: bypass, response: response}
    end

    test "return success for show cluster member", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "GET", "/1.0/cluster/members/test-01", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, data} = Lexdee.get_cluster_member(client, "test-01")
    end
  end
end
