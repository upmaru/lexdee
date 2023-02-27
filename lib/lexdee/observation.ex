defmodule Lexdee.Observation do
  defstruct [:type, :reference, :event]

  @type t :: %__MODULE__{
          type: String.t(),
          reference: map(),
          event: struct()
        }

  def new(params, reference) do
    %__MODULE__{
      type: params["type"],
      reference: reference,
      event: build_event(params)
    }
  end

  defp build_event(params) do
    {:ok, datetime, _} =
      if timestamp = params["timestamp"] do
        DateTime.from_iso8601(timestamp)
      else
        {:ok, DateTime.utc_now(), 0}
      end

    %Lexdee.Event{
      location: params["location"],
      project: params["project"],
      timestamp: datetime,
      object: build_object(params)
    }
  end

  defp build_object(%{"state" => message})
       when is_binary(message),
       do: %Lexdee.Message{body: message}

  defp build_object(%{"type" => "operation", "metadata" => metadata})
       when is_map(metadata) do
    metadata =
      metadata
      |> Enum.map(fn
        {"metadata", value} when is_map(value) ->
          parse_metadata(value, metadata["class"])

        {key, value} when key in ["created_at", "updated_at"] ->
          {:ok, datetime, _} = DateTime.from_iso8601(value)

          {String.to_atom(key), datetime}

        {key, value} ->
          {String.to_atom(key), value}
      end)

    struct(Lexdee.Operation, metadata)
  end

  defp build_object(%{"type" => "lifecycle", "metadata" => metadata})
       when is_map(metadata) do
    metadata =
      metadata
      |> Enum.map(fn {key, value} ->
        {String.to_atom(key), value}
      end)

    struct(Lexdee.Lifecycle, metadata)
  end

  defp parse_metadata(metadata, "websocket") do
    metadata =
      metadata
      |> Enum.map(fn {key, value} ->
        {String.to_atom(key), value}
      end)

    {:metadata, struct(Lexdee.Websocket, metadata)}
  end

  defp parse_metadata(metadata, _), do: {:metadata, metadata}
end
