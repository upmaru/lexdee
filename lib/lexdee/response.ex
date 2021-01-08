defmodule Lexdee.Response do
  @behaviour Tesla.Middleware

  def call(env, next, _options) do
    env
    |> Tesla.run(next)
    |> case do
      {:ok, %{status: status, body: %{"metadata" => response}} = env}
      when status in [200, 201, 202] ->
        {:ok, %{env | body: response}}

      {:ok, %{status: status, body: body} = env} when status in [200] ->
        {:ok, %{env | body: body}}

      {:ok, %{body: response}} ->
        {:error, response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
