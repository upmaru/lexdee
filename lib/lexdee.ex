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
  alias Lexdee.Client

  defdelegate create_client(base_url, cert \\ nil, key \\ nil),
    to: Client,
    as: :new

  alias Lexdee.Profiles

  defdelegate list_profiles(client), to: Profiles, as: :index
  defdelegate create_profile(client, params), to: Profiles, as: :create

  alias Lexdee.Certificates

  defdelegate list_certificates(client), to: Certificates, as: :index
  defdelegate get_certificate(client, id), to: Certificates, as: :show
  defdelegate create_certificate(client, params), to: Certificates, as: :create

  defdelegate update_certificate(client, id, params),
    to: Certificates,
    as: :update

  alias Lexdee.Cluster

  defdelegate get_cluster(client), to: Cluster, as: :show

  alias Cluster.Members

  defdelegate get_cluster_members(client), to: Members, as: :index
  defdelegate get_cluster_member(client, id), to: Members, as: :show

  alias Lexdee.Instances

  defdelegate list_instances(client), to: Instances, as: :index
  defdelegate get_instance(client, id), to: Instances, as: :show

  defdelegate create_instance(client, params, opts \\ []),
    to: Instances,
    as: :create

  defdelegate get_state(client, id), to: Instances.State, as: :show

  defdelegate start_instance(client, id, options \\ []),
    to: Instances.State,
    as: :start

  defdelegate stop_instance(client, id, options \\ []),
    to: Instances.State,
    as: :stop

  defdelegate restart_instance(client, id, options \\ []),
    to: Instances.State,
    as: :restart

  defdelegate create_file(client, id, path, content),
    to: Instances.Files,
    as: :create

  alias Lexdee.Operations

  defdelegate get_operation(client, id), to: Operations, as: :show
end
