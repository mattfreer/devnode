defmodule Devnode.Monitor.NodeSereverTest do
  use ExUnit.Case
  alias Devnode.Monitor.NodeServer, as: NodeServer

  setup do
    pid = :global.whereis_name(NodeServer)
    NodeServer.purge(pid)

    :ok
  end

  test "server is auto started by supervisor" do
    start_link_response = NodeServer.start_link()
    assert {:error, {:already_started, _pid}} = start_link_response
  end

  test "server is restarted by supervisor when it dies" do
    pid1 = :global.whereis_name(NodeServer)
    Process.exit(pid1, :kill)
    :timer.sleep 1000
    assert pid1 != :global.whereis_name(NodeServer)
  end

  test "new nodes are named and added to GenServer state" do
    pid = :global.whereis_name(NodeServer)
    node1 = NodeServer.add_entry(pid, "foo", "bar")
    assert %{ip: _, name: _} = node1

    nodes = NodeServer.entries(pid)
    assert %HashDict{} = nodes
    assert ["foo"] = HashDict.keys(nodes)
    assert [%{ip: _, name: "foo", image: "bar"}] = HashDict.values(nodes)
  end

  test "node names must be unique" do
    pid = :global.whereis_name(NodeServer)
    node1 = NodeServer.add_entry(pid, "foo", "bar")
    assert %{ip: _, name: _} = node1
    node2 = NodeServer.add_entry(pid, "foo", "bar")
    assert {:error, "node names must be unique, foo is already in use"} == node2
  end
end
