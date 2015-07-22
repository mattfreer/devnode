defmodule Devnode.Client.Help do
  def msg(["build" = cmd]) do
    "build --name=node_name"
    |> add_header(cmd)
  end

  def msg([cmd], "runtime_config") do
    requires_runtime_config(cmd)
  end

  defp requires_runtime_config(cmd) do
    """
    The `#{cmd}` command requires a `.devnoderc` config file to be present in the current working directory
    """
  end

  defp add_header(msg, cmd) do
    """
    The `#{cmd}` command should be used as follows:
    #{msg}
    """
  end
end

