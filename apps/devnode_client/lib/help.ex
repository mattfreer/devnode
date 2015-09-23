defmodule Devnode.Client.Help do
  def msg([cmd], "Requires runtime config" <> _rest) do
    requires_runtime_config(cmd)
  end

  def msg([cmd], "Registry already exists" <> _rest) do
    """
    The `#{cmd}` command will only replace an existing registry if the `--force` option is specified
    """
  end

  def msg(["build" = cmd], details) do
    "build --name=node_name"
    |> add_cmd_usage(cmd)
    |> add_details(details)
  end

  def msg([cmd], "registry_exists") do
    """
    The `#{cmd}` command will only replace an existing registry if the `--force` option is specified
    """
  end

  defp requires_runtime_config(cmd) do
    """
    The `#{cmd}` command requires a `.devnoderc` config file to be present in the current working directory
    """
  end

  defp add_cmd_usage(msg, cmd) do
    """
    The `#{cmd}` command should be used as follows:
    #{msg}
    """
  end

  defp add_details(msg, details) do
    """
    #{details}
    #{msg}
    """
  end
end

