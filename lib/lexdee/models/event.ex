defmodule Lexdee.Event do
  defstruct [:location, :project, :object, :timestamp]

  @type t :: %__MODULE__{
          location: String.t(),
          project: String.t(),
          object: struct,
          timestamp: DateTime.t()
        }
end
