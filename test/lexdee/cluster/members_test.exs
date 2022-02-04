defmodule Lexdee.Cluster.MembersTest do
  use ExUnit.Case

  describe "index recursion 1" do
    setup do
      response =
        File.read!(
          "test/support/fixtures/responses/cluster/member/index_recursion_one.json"
        )

      bypass = Bypass.open()
      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, client: client, bypass: bypass, response: response}
    end

    test "return success list cluster members", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "GET", "/1.0/cluster/members", fn conn ->
        %{"recursion" => "1"} = conn.query_params

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, _data} =
               Lexdee.list_cluster_members(client, query: [recursion: 1])
    end
  end

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

      assert {:ok, _data} = Lexdee.get_cluster_member(client, "test-01")
    end
  end
end
