defmodule Devnode.Client.Help do
  alias Devnode.Client.ImageRepo

  def msg([cmd], "no match" <> _rest) do
    """
    The `#{cmd}` command has not been recognised
    """
  end

  def msg([cmd], "Devnode.Client.ImageRepo.exists?/0" <> _rest) do
    requires_image_repo(cmd)
  end

  def msg([cmd], "Devnode.Client.RuntimeConfig.exists?/0" <> _rest) do
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

  defp requires_image_repo(cmd) do
    """
    The `#{cmd}` command expects an image repository to be located at `#{ImageRepo.dir}`
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

