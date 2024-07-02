defmodule Lexdee.Behaviour do
  @callback get_state(struct, binary, Keyword.t()) :: {:ok, map} | {:error, any}

  @callback get_instance(struct, binary) :: {:ok, map} | {:error, any}
  @callback get_instance(struct, binary, Keyword.t()) ::
              {:ok, map} | {:error, any}
  @callback get_project(struct, binary) :: {:ok, map} | {:error, any}
  @callback create_project(struct, map) :: {:ok, map} | {:error, any}
  @callback show_instance_log(struct, binary, binary) ::
              {:ok, binary} | {:error, any}
  @callback show_instance_log(struct, binary, binary, Keyword.t()) ::
              {:ok, binary} | {:error, any}

  @callback execute_command(struct, binary, binary) ::
              {:ok, any} | {:error, any}
  @callback execute_command(struct, binary, binary, Keyword.t()) ::
              {:ok, any} | {:error, any}
  @callback wait_for_operation(struct, map, Keyword.t()) ::
              {:ok, any} | {:error, any}
  @callback create_profile(struct, map) :: {:ok, any} | {:error, any}
  @callback update_profile(struct, binary, map) :: {:ok, any} | {:error, any}
  @callback create_certificate(struct, map) :: {:ok, any} | {:error, any}
  @callback create_instance(struct, map, Keyword.t()) ::
              {:ok, map} | {:error, map}

  @callback delete_instance(struct, binary) :: {:ok, any} | {:error, any}
  @callback delete_instance(struct, binary, Keyword.t()) ::
              {:ok, map} | {:error, any}

  @callback start_instance(struct, binary) :: {:ok, any} | {:error, any}
  @callback start_instance(struct, binary, Keyword.t()) ::
              {:ok, map} | {:error, any}

  @callback restart_instance(struct, binary) :: {:ok, any} | {:error, any}
  @callback restart_instance(struct, binary, Keyword.t()) ::
              {:ok, map} | {:error, any}
  @callback stop_instance(struct, binary, keyword) :: {:ok, any} | {:error, any}

  @callback list_cluster_members(struct) :: {:ok, list}
  @callback get_cluster_member(struct, binary) :: {:ok, map}
end
