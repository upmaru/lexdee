defmodule Lexdee.Response do
  @behaviour Tesla.Middleware

  def call(env, next, _options) do
    env
    |> Tesla.run(next)
    |> case do
      {:ok, %{status: status, body: %{"metadata" => response}}}
      when status in [200, 201, 202] ->
        {:ok, response}

      {:ok, %{body: response}} ->
        {:error, response}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
