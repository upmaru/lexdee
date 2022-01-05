defmodule Lexdee.Networks do
  use Tesla

  @path "/1.0/networks"

  def base_path, do: @path

  def index(client, options \\ []), do: get(client, @path, options)
end
