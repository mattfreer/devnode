defmodule Devnode.Client.Command do
  alias Devnode.Client.FileHelper, as: FileHelper
  alias Devnode.Client.ImageRepo
  alias Devnode.Client.NodeScaffold
  alias Devnode.Client.RegistryScaffold
  alias Devnode.Client.RuntimeConfig
  alias Devnode.Client.RuntimeConfigError
  alias Devnode.Client.Node

  @build_question "Please specify the image that you wish to use:"

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
    |> HashDict.values
    |> Enum.map(fn(i) -> Map.values(i) end)
    |> Table.format(padding: 4)
  end

  defp build_node(values) do
    requires_runtime_config
    images = ImageRepo.list(ImageRepo.dir)
    selection = image_selection(images)

    if(Enum.member?(images, selection)) do
      scaffold_node(Keyword.get(values, :name), selection)
    end
  end

  defp build_registry(values) do
    registry_path = Application.get_env(:paths, :registry)

    RegistryScaffold.build(registry_path, registry_credentials)
    |> registry_summary
  end

  defp registry_credentials do
    %{
      name: "registry",
      ip: Application.get_env(:ips, :registry)
    }
  end

  defp registry_summary(credentials) do
    "#{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }"
  end

  defp requires_runtime_config do
    unless RuntimeConfig.exists? do
      raise RuntimeConfigError
    end
  end

  defp scaffold_node(name, image) when byte_size(name) > 0 do
    credentials = NodeScaffold.build(FileHelper.cwd, Node.new(name, image))
    "#{ Map.get(credentials, :image) }    #{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }"
  end

  defp image_selection(images) do
    IO.gets("#{@build_question}\n#{Enum.join(images, "\n")}\n")
    |> String.rstrip
  end
end
