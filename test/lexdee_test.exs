defmodule LexdeeTest do
  use ExUnit.Case

  test "create client" do
    assert %Tesla.Client{adapter: adapter} =
             Lexdee.create_client(
               "http://localhost:8443",
               "somecert",
               "somekey",
               timeout: 300_000
             )

    assert {Tesla.Adapter.Mint, :call, [options]} = adapter

    assert Keyword.fetch!(options, :timeout) == 300_000
  end
end
