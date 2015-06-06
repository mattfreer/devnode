defmodule Devnode.Monitor.NodeServer do
  use GenServer
  alias Devnode.Monitor.NodeList, as: NodeList

  # Client
  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def add_entry(node_server, name) do
    GenServer.call(node_server, {:add_entry, %{name: name}})
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
  def init(_)do
    {:ok, new_list}
  end

  def handle_call({:add_entry, new_entry}, _pid, node_list) do
    new_state = NodeList.add_entry(node_list, new_entry)

    case new_state do
      e = {:error, _} -> {:reply, e, node_list}
      _result -> {:reply, NodeList.get(new_state, new_entry.name) , new_state}
    end
  end

  def handle_call(:entries, _pid, node_list) do
    {:reply, node_list.entries, node_list}
  end

  def handle_cast(:purge, _node_list) do
    {:noreply, new_list}
  end
end
