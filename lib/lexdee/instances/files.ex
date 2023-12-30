defmodule Lexdee.Instances.Files do
  use Tesla

  alias Lexdee.Instances

  @path "/files"

  def create(client, instance, file_path, content, options \\ []) do
    query = Keyword.get(options, :query)
    project = Keyword.get(query, :project)
    type = Keyword.get(query, :type, "file")

    path =
      [Instances.base_path(), instance, @path]
      |> Path.join()

    post(client, path, content,
      query: [path: file_path, project: project],
      headers: [
        {"content-type", "application/octet-stream"},
        {"X-LXD-type", type}
      ]
    )
  end
end
