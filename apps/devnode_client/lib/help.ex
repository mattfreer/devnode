defmodule Devnode.Client.Help do
  alias Devnode.Client.ImageRepo

  def msg([_head|_tail] = cmds, "no match" <> _rest) do
    """
    The `#{Enum.join(cmds, " ")}` command has not been recognised
    """
  end

  def msg([_head|_tail] = cmds, "Devnode.Client.ImageRepo.exists?/0" <> _rest) do
    Enum.join(cmds, " ") |> requires_image_repo
  end

  def msg([_head|_tail] = cmds, "Devnode.Client.RuntimeConfig.exists?/0" <> _rest) do
    Enum.join(cmds, " ") |> requires_runtime_config
  end

  def msg([_head|_tail] = cmds, "Registry already exists" <> _rest) do
    """
    The `#{Enum.join(cmds, " ")}` command will only replace an existing registry if the `--force` option is specified
    """
  end

  def msg(["build" = cmd], details) do
    "build --name=node_name"
    |> add_cmd_usage(cmd)
    |> add_details(details)
  end

  defp requires_image_repo(cmd) do
    """
    The `#{cmd}` command expects an image repository to be located at `#{ImageRepo.dir}`.
    The location for the image repository is specified in the `devnoderc` config file.
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

