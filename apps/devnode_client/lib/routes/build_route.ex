defmodule Devnode.Client.BuildRoute do
  alias Devnode.Client.ImageRepo
  alias Devnode.Client.NodeScaffold
  alias Devnode.Client.RuntimeConfig
  alias Devnode.Client.NodeServerProxy
  alias Devnode.Client.FileHelper
  alias Devnode.Types

  @build_question "Please specify the image that you wish to use:"

  use Towel

  @spec execute(Keyword.t) :: Types.result_monad
  def execute(values) do
    node_credentials(values)
    |> register_node
    |> scaffold_node
    |> node_summary
  end

  @spec node_credentials(Keyword.t) :: Types.result_monad
  defp node_credentials(options) do
    ok(%{})
    |> add_name(options)
    |> add_image
  end

  @spec add_image(Types.result_monad) :: Types.result_monad
  defp add_image(result) do
    bind(result, fn(credentials) ->
      requires_runtime_config(&ImageRepo.dir/0)
      |> images
      |> image_selection
      |> validate_image_selection
      |> add_to_credentials(credentials)
    end)
  end

  @spec add_name(Types.result_monad, Keyword.t) :: Types.result_monad
  defp add_name(result, options) do
    bind(result, fn(credentials) ->
      node_name(options)
      |> add_to_credentials(credentials)
    end)
  end

  @spec node_name(Keyword.t) :: Types.result_monad
  defp node_name(options) do
    if Keyword.has_key?(options, :name) do
      ok(%{name: Keyword.get(options, :name)});
    else
      error("Requires `--name` option.");
    end
  end

  @spec add_to_credentials(Types.result_monad, Map.t) :: Types.result_monad
  defp add_to_credentials(result, credentials) do
    bind(result, fn(map) ->
      Result.ok(Map.merge(credentials, map))
    end)
  end

  @spec images(Types.result_monad) :: Types.result_monad
  defp images(result) do
    bind(result, fn(path) ->
      ok(ImageRepo.list(path))
    end)
  end

  @spec image_selection(Types.result_monad) :: Types.result_monad
  defp image_selection(list) do
    bind(list, fn(images) ->
      case ask_build_question(images) do
        "" -> error("No image specified.");
        image_name -> ok(%{selection: image_name, list: images})
      end
    end)
  end

  @spec validate_image_selection(Types.result_monad) :: Types.result_monad
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

  @spec requires_runtime_config((... -> any)) :: Types.result_monad
  defp requires_runtime_config(f) do
    if RuntimeConfig.exists? do
      ok(f.());
    else
      error("Requires runtime config");
    end
  end

  @spec register_node(Types.result_monad) :: Types.result_monad
  defp register_node(result) do
    bind(result, fn(credentials) ->
      NodeServerProxy.new(credentials) |> Result.wrap
    end)
  end

  @spec scaffold_node(Types.result_monad) :: Types.result_monad
  defp scaffold_node(result) do
    bind(result, fn(credentials) ->
      NodeScaffold.build(FileHelper.cwd, credentials)
    end)
  end

  @spec node_summary(Types.result_monad) :: Types.result_monad
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

