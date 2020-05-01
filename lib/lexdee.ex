defmodule Lexdee do
  @moduledoc """
  Documentation for Lexdee.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Lexdee.hello()
      :world

  """
  alias Lexdee.Certificates

  defdelegate list_certificates(client), to: Certificates, as: :index
  defdelegate get_certificate(client, id), to: Certificates, as: :show
  defdelegate create_certificate(client, params), to: Certificates, as: :create

  defdelegate update_certificate(client, id, params),
    to: Certificates,
    as: :update

  alias Lexdee.Instances

  defdelegate list_instances(client), to: Instances, as: :index
  defdelegate create_instance(client, params), to: Instances, as: :create

  alias Lexdee.Operations

  defdelegate get_operation(client, id), to: Operations, as: :show
end
