defmodule Lexdee.Operation do
  defstruct [
    :id,
    :updated_at,
    :created_at,
    :description,
    :status,
    :err,
    :status_code,
    :may_cancel,
    :resources,
    :metadata,
    :class
  ]
end
