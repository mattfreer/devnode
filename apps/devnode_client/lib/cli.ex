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
    OptionParser.parse(argv)
  end

  defp build_response(options) do
    Devnode.Client.Command.execute(elem(options, 1))
  end

  defp respond(device \\ :erlang.group_leader(), response) do
    IO.write(device, response)
    IO.write(device, "\n")
    response
  end
end
