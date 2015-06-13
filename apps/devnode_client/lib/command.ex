defmodule Devnode.Client.Command do
  alias Devnode.Client.FileHelper, as: FileHelper

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
    name = Keyword.get(values, :name)
    credentials = Devnode.Client.Scaffold.build(FileHelper.cwd, name)
    "#{ Map.get(credentials, :ip) }    #{ Map.get(credentials, :name) }"
  end
end
