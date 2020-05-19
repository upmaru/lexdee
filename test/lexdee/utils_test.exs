defmodule Lexdee.UtilsTest do
  use ExUnit.Case

  defmodule Resource do
    @path "/1.0/resource"

    use Lexdee.Utils
  end

  describe "get_id" do
    test "builds the right path when id is passed" do
      assert Resource.get_id("something") == "/1.0/resource/something"
    end

    test "builds the right path when path is passed" do
      assert Resource.get_id("/1.0/resource/something") ==
               "/1.0/resource/something"
    end
  end
end
