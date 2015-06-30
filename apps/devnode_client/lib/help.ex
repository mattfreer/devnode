defmodule Devnode.Client.Help do
  def msg(["build" = cmd]) do
    "build --name=node_name"
    |> add_header(cmd)
  end

  defp add_header(msg, cmd) do
    """
    The `#{cmd}` command should be used as follows:
    #{msg}
    """
  end
end

