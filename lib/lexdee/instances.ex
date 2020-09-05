defmodule Lexdee.Instances do
  use Tesla

  @path "/1.0/instances"

  @spec base_path :: binary()
  def base_path, do: @path

  @spec index(Tesla.Client.t()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def index(client), do: Tesla.get(client, @path)

  @spec show(Tesla.Client.t(), binary()) :: {:error, any} | {:ok, Tesla.Env.t()}
  def show(client, id), do: Tesla.get(client, id)

  @spec create(Tesla.Client.t(), map, Keyword.t()) ::
          {:error, any} | {:ok, Tesla.Env.t()}
  def create(client, params, opts \\ []),
    do: post(client, @path, params, opts)
end
