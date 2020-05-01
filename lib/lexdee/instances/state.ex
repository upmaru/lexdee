defmodule Lexdee.Instances.State do
  @path "/state"

  def show(client, id), do: Tesla.get(client, Path.join(id, @path))

  def start(client, id, options),
    do: execute(client, id, %{"action" => "start"}, options)

  def stop(client, id, options),
    do: execute(client, id, %{"action" => "stop"}, options)

  def restart(client, id, options),
    do: execute(client, id, %{"action" => "restart"}, options)

  defp execute(client, id, base_params, options) do
    params =
      Map.merge(base_params, %{
        "timeout" => Keyword.get(options, :timeout, 30),
        "force" => Keyword.get(options, :force, false),
        "stateful" => Keyword.get(options, :stateful, false)
      })

    Tesla.put(client, Path.join(id, @path), params)
  end
end
