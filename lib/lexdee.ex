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

  alias Lexdee.Projects

  defdelegate list_projects(client, opts \\ []), to: Projects, as: :index
  defdelegate get_project(client, id), to: Projects, as: :show
  defdelegate create_project(client, params), to: Projects, as: :create

  defdelegate update_project(client, id, params, opts \\ []),
    to: Projects,
    as: :update

  alias Lexdee.Profiles

  defdelegate list_profiles(client, opts \\ []), to: Profiles, as: :index
  defdelegate get_profile(client, id), to: Profiles, as: :show
  defdelegate update_profile(client, id, params), to: Profiles, as: :update
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

  defdelegate list_cluster_members(client, opts \\ []), to: Members, as: :index
  defdelegate get_cluster_member(client, id), to: Members, as: :show

  alias Lexdee.Instances

  defdelegate execute_command(client, id, commands, opts \\ []),
    to: Instances.Exec,
    as: :perform

  defdelegate list_instances(client, options \\ []), to: Instances, as: :index
  defdelegate get_instance(client, id), to: Instances, as: :show

  defdelegate delete_instance(client, id, opts \\ []),
    to: Instances,
    as: :remove

  defdelegate create_instance(client, params, opts \\ []),
    to: Instances,
    as: :create

  defdelegate show_instance_log(client, instance, file_name, opts \\ []),
    to: Instances.Logs,
    as: :show

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

  defdelegate create_file(client, id, path, content, options \\ []),
    to: Instances.Files,
    as: :create

  alias Lexdee.Operations

  defdelegate get_operation(client, id), to: Operations, as: :show

  defdelegate wait_for_operation(client, id, options \\ []),
    to: Operations,
    as: :wait

  alias Lexdee.Networks

  defdelegate list_networks(client, options \\ []),
    to: Networks,
    as: :index

  defdelegate list_network_leases(client, id, options \\ []),
    to: Networks.Leases,
    as: :index
end
