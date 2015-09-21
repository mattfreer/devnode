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
    if (Enum.count(nodes) > 0) do
      nodes
      |> ports
      |> Enum.max
    else
      @start_port
    end
  end

  defp free_port?(port) do
    case System.cmd("lsof", ["-iTCP:#{port}"], stderr_to_stdout: true) do
      {"", 1} -> true
      {_output, 0} -> false
    end
  end

  defp ports(list) do
    Enum.map(list, fn(node) -> elem(node, 1).port end)
  end
end

