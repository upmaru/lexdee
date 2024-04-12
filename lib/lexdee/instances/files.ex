defmodule Lexdee.Instances.Files do
  @path "/files"

  def create(client, id, path, content, options \\ []) do
    query = Keyword.get(options, :query)
    project = Keyword.get(query, :project)

    Tesla.post(client, Path.join(id, @path), content,
      query: [path: path, project: project],
      headers: [{"content-type", "application/octet-stream"}]
    )
  end
end
