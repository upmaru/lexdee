defmodule Lexdee.Instances do
  use Tesla

  @path "/1.0/instances"

  @spec base_path :: binary()
  def base_path, do: @path

  @spec index(Tesla.Client.t(), Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def index(client, options \\ []), do: Tesla.get(client, @path, options)

  @spec show(Tesla.Client.t(), binary()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def show(client, id), do: Tesla.get(client, Path.join(@path, id))

  @spec create(Tesla.Client.t(), map, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def create(client, params, opts \\ []),
    do: post(client, @path, params, opts)

  @spec remove(Tesla.Client.t(), binary()) ::
          {:ok, Tesla.Env.t()} | {:error, any()}
  def remove(client, id),
    do: delete(client, Path.join(@path, id))
end
