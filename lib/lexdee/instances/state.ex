defmodule Lexdee.Instances.State do
  alias Lexdee.Instances

  @path "/state"

  @spec show(Tesla.Client.t(), binary, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def show(client, id, options \\ []),
    do: Tesla.get(client, Path.join(id, @path), options)

  @spec start(Tesla.Client.t(), binary, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def start(client, id, options \\ []),
    do: execute(client, id, %{"action" => "start"}, options)

  @spec stop(Tesla.Client.t(), binary, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def stop(client, id, options \\ []),
    do: execute(client, id, %{"action" => "stop"}, options)

  @spec restart(Tesla.Client.t(), binary, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def restart(client, id, options \\ []),
    do: execute(client, id, %{"action" => "restart"}, options)

  defp execute(client, id, base_params, options) do
    params =
      Map.merge(base_params, %{
        "timeout" => Keyword.get(options, :timeout, 30),
        "force" => Keyword.get(options, :force, false),
        "stateful" => Keyword.get(options, :stateful, false)
      })

    Tesla.put(
      client,
      Path.join([Instances.base_path(), id, @path]),
      params,
      options
    )
  end
end
