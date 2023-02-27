defmodule Lexdee.ObservationHandler do
  @type error_reason :: binary() | atom()

  @callback handle_event(observation :: Lexdee.Observation.t()) ::
              {:ok, term} | :ok | {:error, error_reason} | :error
end
