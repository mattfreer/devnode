defmodule Devnode.Monitor.NodeList do
  defstruct entries: HashDict.new

  @ip_range "192.168.124"

  def new() do
    %Devnode.Monitor.NodeList{}
  end

  def add_entry(%Devnode.Monitor.NodeList{entries: entries} = node_list, entry) do
    case validate_entry(node_list, entry) do
      {:ok, entry} -> add(node_list, entry)
      error -> error
    end
  end

  def get(%Devnode.Monitor.NodeList{entries: entries} = node_list, key) do
    HashDict.get(entries, key)
  end

  defp validate_entry(list, entry) do
    case HashDict.has_key?(list.entries, entry.name) do
      true -> {:error, "node names must be unique, #{ entry.name } is already in use"}
      false -> {:ok, entry}
    end
  end

  defp add(%Devnode.Monitor.NodeList{entries: entries} = node_list, entry) do
    entry = Map.put(entry, :ip, next_ip(entries))
    new_entries = HashDict.put(entries, entry.name, entry)
    %Devnode.Monitor.NodeList{node_list | entries: new_entries }
  end

  defp next_ip(nodes) do
    "#{ @ip_range }.#{ last_host(nodes) + 1 }"
  end

  defp last_host(nodes) do
    if (Enum.count(nodes) > 0) do
      nodes
      |> ip_addresses
      |> ip_hosts
      |> Enum.max
    else
      0
    end
  end

  defp ip_addresses(list) do
    Enum.map(list, fn(node) -> elem(node, 1).ip end)
  end

  defp ip_hosts(list) do
    Enum.map(list, fn(ip) ->
      Regex.run(~r/[^.]+$/, ip)
      |> List.first
      |> String.to_integer
    end)
  end
end
