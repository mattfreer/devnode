defmodule Devnode.Client.Command do
  alias Devnode.Client.FileHelper, as: FileHelper
  alias Devnode.Client.ImageRepo
  alias Devnode.Client.NodeScaffold
  alias Devnode.Client.RegistryScaffold
  alias Devnode.Client.RuntimeConfig
  alias Devnode.Client.Node

  @build_question "Please specify the image that you wish to use:"
  use Towel

  @typep result_monad :: {:ok, any} | {:error, any}

  def execute(options) do
    f = elem(options, 1) |> match
    f.(elem(options, 0))
  end

  def match(list) do
    cond do
      includes?(list, "list") -> &list_nodes/1
      includes?(list, "build") -> &build_node/1
      includes?(list, "build-registry") -> &build_registry/1

      true ->
        fn(_values) -> "no match" end
    end
  end

  defp includes?(list, str) do
    Enum.any?(list, fn(x) -> x == str end)
  end

  defp list_nodes(_values) do
    Devnode.Client.Node.list
    |> Map.values
    |> Enum.map(fn(i) -> Map.values(i) end)
    |> Table.format(padding: 4)
  end

  defp build_node(values) do
    node = requires_runtime_config(&ImageRepo.dir/0)
    |> images
    |> get_image_selection
    |> valid_image_selection?
    |> scaffold_node(Keyword.get(values, :name))
    |> node_summary

    case node do
      {:ok, n} -> n
      {:error, msg} -> raise msg
    end
  end

  @spec images(result_monad) :: result_monad
  defp images(result) do
    bind(result, fn(path) ->
      ok(ImageRepo.list(path))
    end)
  end

  @spec get_image_selection(result_monad) :: result_monad
  defp get_image_selection(list) do
    bind(list, fn(images) ->
      case ask_build_question(images) do
        "" -> error("No image specified.");
        image_name -> ok(%{selection: image_name, list: images})
      end
    end)
  end

  @spec valid_image_selection?(result_monad) :: result_monad
  defp valid_image_selection?(result) do
    bind(result, fn(map) ->
      list = Map.get(map, :list)
      image = Map.get(map, :selection)

      if Enum.member?(list, image) do
        ok(image)
      else
        error("The image named '#{image}', is not available.")
      end
    end)
  end

  @spec requires_runtime_config(any) :: result_monad
  defp requires_runtime_config(any) do
    if RuntimeConfig.exists? do
      ok(any.());
    else
      error("Requires runtime config");
    end
  end

  defp build_registry(values) do
    registry = registry_path
    |> registry_credentials(Keyword.get(values, :force))
    |> scaffold_registry
    |> registry_summary

    case registry do
      {:ok, credentials} -> credentials
      {:error, msg} -> raise msg
    end
  end

  @spec registry_path() :: result_monad
  defp registry_path() do
    Result.wrap(Application.get_env(:devnode_client, :paths) |> Map.get(:registry))
  end

  @spec registry_credentials(result_monad, boolean) :: result_monad
  defp registry_credentials(result, force) do
    bind(result, fn(registry_path) ->
      Result.ok(%{
        name: "registry",
        ip: Application.get_env(:devnode_client, :ips) |> Map.get(:registry),
        override: force,
        path: registry_path
      })
    end)
  end

  @spec scaffold_registry(result_monad) :: result_monad
  defp scaffold_registry(result) do
    bind(result, fn(credentials) ->
      path = Map.get(credentials, :path)
      Result.wrap(RegistryScaffold.build(path, Map.delete(credentials, :path)))
    end)
  end

  @spec registry_summary(result_monad) :: result_monad
  defp registry_summary(result) do
    bind(result, fn(credentials) ->
      Result.wrap("#{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }")
    end)
  end

  @spec scaffold_node(result_monad, String.t) :: result_monad
  defp scaffold_node(result, name) do
    bind(result, fn(image) ->
      NodeScaffold.build(FileHelper.cwd, Node.new(name, image))
    end)
  end

  @spec node_summary(result_monad) :: result_monad
  defp node_summary(result) do
    bind(result, fn(n) ->
      Result.wrap("#{ Map.get(n, :image) }    #{ Map.get(n, :ip) }    #{ Map.get(n, :port) }    #{ Map.get(n, :name) }")
    end)
  end

  @spec ask_build_question(list) :: String.t
  defp ask_build_question(images) do
    IO.gets("#{@build_question}\n#{Enum.join(images, "\n")}\n")
    |> String.rstrip
  end
end
