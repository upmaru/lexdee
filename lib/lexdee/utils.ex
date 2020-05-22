defmodule Lexdee.Utils do
  defmacro __using__(_) do
    quote do
      def get_id(id) do
        if id =~ @path,
          do: id,
          else: Path.join(@path, id)
      end
    end
  end
end
