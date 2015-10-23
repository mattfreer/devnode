defmodule Devnode.Monitor.NodeServerTest do
  use ExUnit.Case
  alias Devnode.Monitor.NodeServer
  alias Devnode.Support.TestDir

  setup do
    pid = :global.whereis_name(NodeServer)

    on_exit fn ->
      NodeServer.purge(pid)
      TestDir.remove
    end

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

  test "when server is restarted it maintains state" do
    pid = :global.whereis_name(NodeServer)
    NodeServer.add_entry(pid, %{name: "a", image: "foo"})
    NodeServer.add_entry(pid, %{name: "b", image: "bar"})

    GenServer.cast(pid, :bad_cast)
    :timer.sleep 1000

    pid1 = :global.whereis_name(NodeServer)
    nodes = NodeServer.entries(pid1)
    assert %{} = nodes
    assert ["a", "b"] = Map.keys(nodes)
  end

  test "new nodes are named and added to GenServer state" do
    pid = :global.whereis_name(NodeServer)
    node1 = NodeServer.add_entry(pid, %{name: "foo", image: "bar"})
    assert %{ip: _, name: _} = node1

    nodes = NodeServer.entries(pid)
    assert %{} = nodes
    assert ["foo"] = Map.keys(nodes)
    assert [%{ip: _, name: "foo", image: "bar"}] = Map.values(nodes)
  end

  test "node names must be unique" do
    pid = :global.whereis_name(NodeServer)
    node1 = NodeServer.add_entry(pid, %{name: "foo", image: "bar"})
    assert %{ip: _, name: _} = node1
    node2 = NodeServer.add_entry(pid, %{name: "foo", image: "bar"})
    assert {:error, "node names must be unique, foo is already in use"} == node2
  end
end
