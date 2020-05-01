defmodule Lexdee.Instances.Files do
  @path "/files"

  alias Tesla.Multipart

  def create(client, id, path, content) do
    Tesla.post(client, Path.join(id, @path), content,
      query: [path: path],
      headers: [{"content-type", "application/octet-stream"}]
    )
  end
end
