defmodule Devnode.Monitor.NodeList do
  defstruct entries: %{}

  import Devnode.Monitor.NodePort, only: [next_free_port: 1, highest_port: 1]
  alias Devnode.Monitor.Node

  @type nodes :: %{atom => Devnode.Monitor.Node.t}
  @type t :: %__MODULE__{:entries => nodes}
  @ip_range "192.168.124"

  def new() do
    %Devnode.Monitor.NodeList{}
  end

  @spec add_entry(__MODULE__.t, Node.t) :: Node.t | {:error, String.t}
  def add_entry(%Devnode.Monitor.NodeList{} = node_list, entry) do
    case validate_entry(node_list, entry) do
      {:ok, entry} -> add(node_list, entry)
      error -> error
    end
  end

  def get(%Devnode.Monitor.NodeList{entries: entries}, key) do
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
    host = last_host(nodes) + 1
    "#{ @ip_range }.#{ Integer.to_string(host) }"
  end

  @spec last_host(nodes) :: integer
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
