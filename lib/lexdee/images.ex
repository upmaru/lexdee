defmodule Lexdee.Images do
  use Tesla

  @path "/1.0/images"

  def remove(client, fingerprint, options \\ []) do
    delete(client, Path.join(@path, fingerprint), options)
  end
end
