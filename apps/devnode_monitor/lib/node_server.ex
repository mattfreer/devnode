defmodule Devnode.Monitor.NodeServer do
  use GenServer
  alias Devnode.Monitor.NodeList, as: NodeList
  alias Devnode.Monitor.Node

  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def add_entry(node_server, credentials) do
    GenServer.call(node_server, {:add_entry, Map.merge(%Node{}, credentials)})
  end

  def entries(node_server) do
    GenServer.call(node_server, :entries)
  end

  def purge(node_server) do
    GenServer.cast(node_server, :purge)
  end

  defp new_list do
    NodeList.new()
  end

  # Server
  def init(_) do
    state = case Devnode.Monitor.NodeStash.read do
      {:error, _} -> new_list
      {:ok, value} -> value
    end

    {:ok, state}
  end

  def handle_call({:add_entry, new_entry}, _pid, node_list) do
    new_state = NodeList.add_entry(node_list, new_entry)

    case new_state do
      e = {:error, _} -> {:reply, e, node_list}
      _ -> entry_added(new_state, new_entry)
    end
  end

  def handle_call(:entries, _pid, node_list) do
    {:reply, node_list.entries, node_list}
  end

  def handle_cast(:purge, _node_list) do
    list = new_list
    _ = persist(list)
    {:noreply, list}
  end

  defp entry_added(new_state, new_entry) do
    _ = persist(new_state)
    {:reply, NodeList.get(new_state, Map.get(new_entry, :name)) , new_state}
  end

  defp persist(state) do
    Devnode.Monitor.NodeStash.write(state)
  end
end
