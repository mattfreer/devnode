defmodule Devnode.Client.CLI do
  alias Devnode.Client.Help
  alias Devnode.Client.RuntimeConfigError

  def main(argv) do
    case Devnode.Client.start do
      {:ok, _} -> process(argv)
      error -> respond(:stderr, error)
    end
  end

  defp process(argv) do
    :timer.sleep 1000
    get_options(argv)
      |> build_response
      |> respond
  end

  defp get_options(argv) do
    switches = [name: :string]
    aliases = [n: :name]
    OptionParser.parse(argv, switches: switches, aliases: aliases)
  end

  defp build_response(options) do
    Process.flag(:trap_exit, true)

    %Task{pid: pid, ref: ref} = Task.async(fn ->
      {:result, Devnode.Client.Command.execute(options)}
    end)

    receive do
      {:EXIT, _pid, reason } -> receive_exit(reason, elem(options, 1))
      {ref, {:result, data}} -> data
    end
  end

  defp receive_exit({ %RuntimeConfigError{}, _}, cmds) do
    Help.msg(cmds, "runtime_config")
  end

  defp receive_exit(_reason, cmds) do
    Help.msg(cmds)
  end

  defp respond(device \\ :erlang.group_leader(), response) do
    IO.write(device, response)
    IO.write(device, "\n")
    response
  end
end
