defmodule Lexdee.ProjectsTest do
  use ExUnit.Case

  setup do
    bypass = Bypass.open()
    client = Lexdee.create_client("http://localhost:#{bypass.port}")

    {:ok, bypass: bypass, client: client}
  end

  describe "projects list" do
    test "return success for list of projects", %{
      bypass: bypass,
      client: client
    } do
      response =
        File.read!("test/support/fixtures/responses/projects/index.json")

      Bypass.expect(bypass, "GET", "/1.0/projects", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: projects}} = Lexdee.list_projects(client)
      assert Enum.count(projects) == 2
    end
  end

  describe "project show" do
    test "return success for project show", %{bypass: bypass, client: client} do
      response =
        File.read!("test/support/fixtures/responses/projects/show.json")

      Bypass.expect(bypass, "GET", "/1.0/projects/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: project}} = Lexdee.get_project(client, "test")
      assert %{"config" => _config} = project
    end

    test "project not found", %{bypass: bypass, client: client} do
      response =
        File.read!("test/support/fixtures/responses/projects/not_found.json")

      Bypass.expect(bypass, "GET", "/1.0/projects/notfound", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(404, response)
      end)

      assert {:error, %{"error_code" => 404}} =
               Lexdee.get_project(client, "notfound")
    end
  end

  describe "create project" do
    test "return success for project creation", %{
      bypass: bypass,
      client: client
    } do
      response =
        File.read!("test/support/fixtures/responses/projects/create.json")

      params = %{
        "config" => %{
          "features.networks" => "false",
          "features.profiles" => "false",
          "features.images" => "false",
          "features.storage.volumes" => "false"
        },
        "description" => "test",
        "name" => "test"
      }

      Bypass.expect(bypass, "POST", "/1.0/projects", fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)

        assert params == Jason.decode!(body)

        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: _project}} = Lexdee.create_project(client, params)
    end
  end

  describe "update project" do
    test "return success for update project", %{bypass: bypass, client: client} do
      response =
        File.read!("test/support/fixtures/responses/projects/update.json")

      Bypass.expect(bypass, "PATCH", "/1.0/projects/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("content-type", "application/json")
        |> Plug.Conn.resp(200, response)
      end)

      assert {:ok, %{body: _project}} =
               Lexdee.update_project(client, "test", %{"description" => "test"})
    end
  end
end
