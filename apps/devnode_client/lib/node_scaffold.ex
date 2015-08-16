defmodule Devnode.Client.NodeScaffold do
  @moduledoc """
  This module scaffolds a node. It uses the `Scaffold.Mixin` and
  implements the required functions of the `Scaffolder` behaviour.
  """

  use Devnode.Client.ScaffoldMixin

  require EEx

  @vm_memory 1024
  @registry "192.168.10.10:5000"
  @templates "lib/templates"

  EEx.function_from_file(
    :def,
    :vagrantfile_template,
    Path.expand("vagrant_file.eex", @templates),
    [:ip, :memory, :shared_dirs]
  )

  EEx.function_from_file(
    :def,
    :docker_setup_template,
    Path.expand("docker_setup.eex", @templates),
    [:registry]
  )

  EEx.function_from_file(
    :def,
    :fig_template,
    Path.expand("fig.eex", @templates),
    [:image, :registry, :shared_dirs]
  )

  def tasks(path, credentials) do
    env_path = Path.expand("env", path)
    scripts_path = Path.expand("scripts", path)
    recipes_path = Path.expand("env/recipes", path)

    [
      {__MODULE__, :copy_static_files, [env_path]},
      {__MODULE__, :create_vagrantfile, [env_path, credentials]},
      {__MODULE__, :create_fig_config, [scripts_path, credentials]},
      {__MODULE__, :create_docker_setup, [recipes_path]}
    ]
  end

  def sub_dirs do
    ["app", "scripts", "env/recipes"]
  end

  @doc false
  def create_vagrantfile(path, credentials) do
    template = credentials
    |> Map.get(:ip)
    |> vagrantfile_template(@vm_memory, ["app", "scripts"])

    Path.expand("Vagrantfile", path)
    |> File.write(template)
  end

  @doc false
  def create_fig_config(path, credentials) do
    template = Map.get(credentials, :image)
    |> fig_template(@registry, ["app", "scripts"])

    Path.expand("fig.yml", path)
    |> File.write(template)
  end

  @doc false
  def create_docker_setup(path) do
    Path.expand("docker_setup.sh", path)
    |> File.write(docker_setup_template(@registry))
  end

  @doc false
  def copy_static_files(path) do
    File.copy("lib/templates/bootstrap.sh", Path.expand("bootstrap.sh", path))
  end
end
