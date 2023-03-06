defmodule Lexdee.Message do
  defstruct [:body, :metadata]

  @type t :: %__MODULE__{
          body: String.t(),
          metadata: map() | nil
        }
end
