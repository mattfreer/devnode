defmodule Devnode.Client.CLI do
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
    Devnode.Client.Command.execute(options)
  end

  defp respond(device \\ :erlang.group_leader(), response) do
    IO.write(device, response)
    IO.write(device, "\n")
    response
  end
end
