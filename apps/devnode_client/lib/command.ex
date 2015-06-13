defmodule Devnode.Client.Command do

  def execute(list) do
    list |> match
  end

  def match(list) do
    cond do
      includes?(list, "list") ->
        list_nodes

      true ->
        "no match"
    end
  end

  defp includes?(list, str) do
    Enum.any?(list, fn(x) -> x == str end)
  end

  defp list_nodes do
    Devnode.Client.Node.list
    |> HashDict.values
    |> Enum.map(fn(i) -> Map.values(i) end)
    |> Table.format(padding: 4)
  end
end
