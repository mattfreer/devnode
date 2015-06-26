defmodule Devnode.Client.Command do
  alias Devnode.Client.FileHelper, as: FileHelper
  alias Devnode.Client.ImageRepo
  alias Devnode.Client.Scaffold

  @build_question "Please specify the image that you wish to use:"

  def execute(options) do
    f = elem(options, 1) |> match
    f.(elem(options, 0))
  end

  def match(list) do
    cond do
      includes?(list, "list") -> &list_nodes/1
      includes?(list, "build") -> &build_node/1

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
    images = ImageRepo.list(ImageRepo.dir)

    if(Enum.member?(images, image_selection(images))) do
      name = Keyword.get(values, :name)
      credentials = Scaffold.build(FileHelper.cwd, name)
      "#{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }"
    end
  end

  defp image_selection(images) do
    IO.gets("#{@build_question}\n#{Enum.join(images, "\n")}\n")
    |> String.rstrip
  end
end
