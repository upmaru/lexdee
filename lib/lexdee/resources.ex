defmodule Lexdee.Resources do
  @path "/1.0/resources"

  def show(client, node \\ nil) do
    query =
      if node do
        [target: node]
      else
        []
      end

    Tesla.get(client, @path, query: query)
  end
end
