defmodule Lexdee.ProfilesTest do
  use ExUnit.Case

  describe "profiles list" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/profiles/index.json")

      bypass = Bypass.open()
      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, bypass: bypass, client: client, response: response}
    end

    test "return success for list of profiles", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "GET", "/1.0/profiles", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, profiles} = Lexdee.list_profiles(client)
      assert Enum.count(profiles) == 2
    end
  end

  describe "create profile" do
    setup do
      response =
        File.read!("test/support/fixtures/responses/profiles/create.json")

      bypass = Bypass.open()
      client = Lexdee.create_client("http://localhost:#{bypass.port}")

      {:ok, bypass: bypass, client: client, response: response}
    end

    test "return success for create profile", %{
      bypass: bypass,
      client: client,
      response: response
    } do
      Bypass.expect(bypass, "POST", "/1.0/profiles", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(201, response)
      end)

      assert {:ok, nil} =
               Lexdee.create_profile(client, %{
                 "name" => "some-profile",
                 "description" => "description",
                 "devices" => %{
                   "http" => %{
                     "type" => "proxy",
                     "listen" => "tcp:0.0.0.0:4001",
                     "connect" => "tcp:127.0.0.1:4000"
                   }
                 }
               })
    end
  end
end
