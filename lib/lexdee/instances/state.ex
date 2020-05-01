defmodule Lexdee.Instances.State do
  @path "/state"

  def start(client, id, options) do
    params = %{
      "action" => "start",
      "timeout" => Keyword.get(options, :timeout, 30),
      "force" => Keyword.get(options, :force, false),
      "stateful" => Keyword.get(options, :stateful, false)
    }

    Tesla.put(client, Path.join(id, @path), params)
  end
end
