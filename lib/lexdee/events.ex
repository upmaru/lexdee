defmodule Lexdee.Events do
  use Tesla

  @path "/1.0/events"

  def index(client, opts \\ [query: [type: "operation"]]) do
    Tesla.get(client, @path, headers: [{"upgrade", "websocket"}])
  end
end
