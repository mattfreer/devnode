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
        fn(_values) -> error("no match") end
    end
  end

  defp includes?(list, str) do
    Enum.any?(list, fn(x) -> x == str end)
  end

  @spec list_nodes(Keyword.t) :: result_monad
  defp list_nodes(_values) do
    result = Devnode.Client.Node.list
    |> Map.values
    |> Enum.map(fn(i) -> Map.values(i) end)
    |> Table.format(padding: 4)

    ok(result)
  end

  @spec build_node(Keyword.t) :: result_monad
  defp build_node(values) do
    node_credentials(values)
    |> scaffold_node
    |> node_summary
  end

  @spec node_credentials(Keyword.t) :: result_monad
  defp node_credentials(options) do
    ok(%{})
    |> add_name(options)
    |> add_image
  end

  @spec add_image(result_monad) :: result_monad
  defp add_image(result) do
    bind(result, fn(credentials) ->
      requires_runtime_config(&ImageRepo.dir/0)
      |> images
      |> image_selection
      |> validate_image_selection
      |> add_to_credentials(credentials)
    end)
  end

  @spec add_name(result_monad, Keyword.t) :: result_monad
  defp add_name(result, options) do
    bind(result, fn(credentials) ->
      node_name(options)
      |> add_to_credentials(credentials)
    end)
  end

  @spec node_name(Keyword.t) :: result_monad
  defp node_name(options) do
    if Keyword.has_key?(options, :name) do
      ok(%{name: Keyword.get(options, :name)});
    else
      error("Requires `--name` option.");
    end
  end

  @spec add_to_credentials(result_monad, Map.t) :: result_monad
  defp add_to_credentials(result, credentials) do
    bind(result, fn(map) ->
      Result.ok(Map.merge(credentials, map))
    end)
  end

  @spec images(result_monad) :: result_monad
  defp images(result) do
    bind(result, fn(path) ->
      ok(ImageRepo.list(path))
    end)
  end

  @spec image_selection(result_monad) :: result_monad
  defp image_selection(list) do
    bind(list, fn(images) ->
      case ask_build_question(images) do
        "" -> error("No image specified.");
        image_name -> ok(%{selection: image_name, list: images})
      end
    end)
  end

  @spec validate_image_selection(result_monad) :: result_monad
  defp validate_image_selection(result) do
    bind(result, fn(map) ->
      list = Map.get(map, :list)
      image = Map.get(map, :selection)

      if Enum.member?(list, image) do
        ok(%{image: image})
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

  @spec build_registry(Keyword.t) :: result_monad
  defp build_registry(values) do
    registry_path
    |> registry_credentials(Keyword.get(values, :force))
    |> scaffold_registry
    |> registry_summary
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

  @spec scaffold_node(result_monad) :: result_monad
  defp scaffold_node(result) do
    bind(result, fn(credentials) ->
      NodeScaffold.build(FileHelper.cwd, Node.new(credentials))
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
