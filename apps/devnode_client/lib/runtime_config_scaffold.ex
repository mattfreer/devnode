defmodule Devnode.Client.RuntimeConfigScaffold do
  @moduledoc """
  This module scaffolds a `.devnoderc` file. It uses the
  `Scaffold.Mixin` and implements the required functions of the
  `Scaffolder` behaviour.
  """

  use Devnode.Client.ScaffoldMixin

  require EEx

  @templates "lib/templates"

  EEx.function_from_file(
    :def,
    :devnoderc_template,
    Path.expand("devnoderc.eex", @templates),
    [:image_repo]
  )

  def tasks(path, credentials) do
    [
      {__MODULE__, :create_devnoderc_file, [path, credentials]}
    ]
  end

  def valid?(_path, %{image_repo: _image_repo}) do
    {:ok, "success"}
  end

  def valid?(_path, %{}) do
    {:error, "invalid credentials"}
  end

  @doc false
  def create_devnoderc_file(path, %{image_repo: image_repo}) do
    template = devnoderc_template(image_repo)

    Path.expand(".devnoderc", path)
    |> File.write(template)
  end
end
