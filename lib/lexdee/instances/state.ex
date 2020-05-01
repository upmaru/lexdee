defmodule Lexdee.Instances.State do
  @path "/state"

  def start(client, id, options),
    do:
      Tesla.put(
        client,
        Path.join(id, @path),
        build_params(%{"action" => "start"}, options)
      )

  defp build_params(base, options) do
    Map.merge(base, %{
      "timeout" => Keyword.get(options, :timeout, 30),
      "force" => Keyword.get(options, :force, false),
      "stateful" => Keyword.get(options, :stateful, false)
    })
  end
end
