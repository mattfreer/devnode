defmodule Devnode.Client do

  def start do
    case start_node do
      {:ok, _} -> connect_to_cluster
      error -> error
    end
  end

  def stop do
    stop_node
  end

  def client_name do
    :"dnclient@127.0.0.1"
  end

  def monitor_name do
    :"dnmonitor@127.0.0.1"
  end

  defp start_node do
    :net_kernel.start([Devnode.Client.client_name])
  end

  defp connect_to_cluster do
    case Node.connect(monitor_name) do
      :ignored -> {:error, "#{monitor_name |> Atom.to_string} is not started"}
      false -> {:error, "Failed to connect to #{monitor_name |> Atom.to_string}"}
      true -> {:ok, "connected to cluster"}
    end
  end

  defp stop_node do
    Node.stop
  end
end
