defmodule LexdeeTest do
  use ExUnit.Case
  doctest Lexdee

  test "greets the world" do
    assert Lexdee.hello() == :world
  end
end
