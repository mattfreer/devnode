defmodule Devnode.Client.BuildRegistryRoute do
  alias Devnode.Client.RegistryScaffold
  alias Devnode.Types

  use Towel

  def execute(values) do
    registry_path
    |> registry_credentials(Keyword.get(values, :force))
    |> scaffold_registry
    |> registry_summary
  end

  @spec registry_path() :: Types.result_monad
  defp registry_path() do
    registry_config(:paths) |> Result.wrap
  end

  @spec registry_credentials(Types.result_monad, boolean) :: Types.result_monad
  defp registry_credentials(result, force) do
    bind(result, fn(registry_path) ->
      Result.ok(%{
        name: "registry",
        ip: registry_config(:ips),
        override: force,
        path: registry_path
      })
    end)
  end

  @spec scaffold_registry(Types.result_monad) :: Types.result_monad
  defp scaffold_registry(result) do
    bind(result, fn(credentials) ->
      path = Map.get(credentials, :path)
      Result.wrap(RegistryScaffold.build(path, Map.delete(credentials, :path)))
    end)
  end

  @spec registry_summary(Types.result_monad) :: Types.result_monad
  defp registry_summary(result) do
    bind(result, fn(credentials) ->
      Result.wrap("#{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }")
    end)
  end

  @spec registry_config(atom) :: String.t
  defp registry_config(key) do
    Application.get_env(:devnode_client, key) |> Map.get(:registry)
  end
end

