defmodule Devnode.Client.Node do
  def new(name) do
    :rpc.call(monitor_node, Devnode.Monitor.NodeServer, :add_entry, [monitor_pid, name])
  end

  def list do
    :rpc.call(monitor_node, Devnode.Monitor.NodeServer, :entries, [monitor_pid])
  end

  defp monitor_pid do
    :global.whereis_name(Devnode.Monitor.NodeServer)
  end

  defp monitor_node do
    :"dnmonitor@127.0.0.1"
  end
end
