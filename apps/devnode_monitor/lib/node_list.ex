defmodule Devnode.Monitor.NodeList do
  defstruct entries: %{}

  import Devnode.Monitor.NodePort, only: [next_free_port: 1, highest_port: 1]

  @type t :: %__MODULE__{:entries => Dict.t}
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
    Map.get(entries, key)
  end

  defp validate_entry(list, entry) do
    case Map.has_key?(Map.get(list, :entries), Map.get(entry, :name)) do
      true -> {:error, "node names must be unique, #{ Map.get(entry, :name) } is already in use"}
      false -> {:ok, entry}
    end
  end

  defp add(%Devnode.Monitor.NodeList{entries: entries} = node_list, entry) do
    port = entries |> highest_port |> next_free_port
    entry = Map.put(entry, :ip, next_ip(entries))
    entry = Map.put(entry, :port, port)
    new_entries = Map.put(entries, Map.get(entry, :name), entry)
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
