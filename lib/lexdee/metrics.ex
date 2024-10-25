defmodule Lexdee.Metrics do
  use Tesla

  @path "/1.0/metrics"

  def index(client, options \\ []) do
    Tesla.get(client, @path, options)
  end
end
