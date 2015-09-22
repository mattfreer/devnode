defmodule Devnode.Monitor.NodePort do
  @start_port 7000
  @max_port 65535

  alias Devnode.Monitor.NodePortError

  @spec next_free_port(pos_integer) :: number
  def next_free_port(start = @max_port) do
    raise NodePortError
  end

  def next_free_port(start) do
    next = start + 1
    if free_port?(next) do
      next
    else
      next_free_port(next)
    end
  end

  @spec highest_port(Devnode.Monitor.NodeList.t) :: pos_integer
  def highest_port(nodes) do
    nodes
    |> ports
    |> Enum.max
  end

  defp free_port?(port) do
    case System.cmd("lsof", ["-iTCP:#{port}"], stderr_to_stdout: true) do
      {"", 1} -> true
      {_output, 0} -> false
    end
  end

  defp ports(entries) when map_size(entries) == 0 do
    [@start_port]
  end

  defp ports(entries) do
    Enum.map(entries, fn(node) -> elem(node, 1).port end)
  end
end

