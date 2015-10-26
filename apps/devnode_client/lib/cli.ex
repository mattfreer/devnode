defmodule Devnode.Client.CLI do
  alias Devnode.Client.Help

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
    switches = [name: :string, force: :boolean]
    aliases = [n: :name, f: :force]
    OptionParser.parse(argv, switches: switches, aliases: aliases)
  end

  defp build_response(options) do
    task = Task.async(fn -> Devnode.Client.Router.execute(options) end)
    result(Task.await(task, :infinity), elem(options,1))
  end

  defp result({:ok, msg}, _cmds) do
    msg
  end

  defp result({:error, msg}, cmds) do
    Help.msg(cmds, msg)
  end

  defp respond(device \\ :erlang.group_leader(), response) do
    IO.write(device, response)
    IO.write(device, "\n")
    response
  end
end
