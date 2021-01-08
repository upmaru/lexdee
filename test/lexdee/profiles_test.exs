defmodule Lexdee.ProfilesTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, bypass: bypass, client: client}
  end

  describe "profiles list" do
    test "return success for list of profiles", %{
      bypass: bypass,
      client: client
    } do
      response =
        File.read!("test/support/fixtures/responses/profiles/index.json")

      Bypass.expect(bypass, "GET", "/1.0/profiles", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: profiles}} = Lexdee.list_profiles(client)
      assert Enum.count(profiles) == 2
    end
  end

  describe "create profile" do
    test "return success for create profile", %{
      bypass: bypass,
      client: client
    } do
      response =
        File.read!(
          "test/support/fixtures/responses/profiles/create/success.json"
        )

      Bypass.expect(bypass, "POST", "/1.0/profiles", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(201, response)
      end)

      assert {:ok, %{body: nil}} =
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

    test "return error already exists", %{
      bypass: bypass,
      client: client
    } do
      response =
        File.read!(
          "test/support/fixtures/responses/profiles/create/already_exists.json"
        )

      Bypass.expect(bypass, "POST", "/1.0/profiles", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(500, response)
      end)

      assert {:error, error} =
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

      assert error["error_code"] == 500
    end
  end
end
