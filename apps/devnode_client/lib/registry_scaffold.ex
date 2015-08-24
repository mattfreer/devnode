defmodule Devnode.Client.RegistryScaffold do
  use Devnode.Client.ScaffoldMixin
  alias Devnode.Client.ImageRepo

  require EEx

  @vm_memory 1024
  @templates "lib/templates"

  EEx.function_from_file(
    :def,
    :vagrantfile_template,
    Path.expand("registry_vagrant_file.eex", @templates),
    [:ip, :memory, :shared_dirs]
  )

  def tasks(path, credentials) do
    env_path = Path.expand("env", path)
    app_path = Path.expand("app", path)

    [
      {__MODULE__, :copy_static_files, [env_path]},
      {__MODULE__, :symlink_image_repo, [app_path]},
      {__MODULE__, :create_vagrantfile, [env_path, credentials]}
    ]
  end

  def sub_dirs do
    ["env", "scripts"]
  end

  @doc false
  def copy_static_files(path) do
    File.copy("lib/templates/bootstrap.sh", Path.expand("bootstrap.sh", path))
  end

  @doc false
  def symlink_image_repo(path) do
    File.ln_s(ImageRepo.dir, path)
  end

  @doc false
  def create_vagrantfile(path, credentials) do
    template = credentials
    |> Map.get(:ip)
    |> vagrantfile_template(@vm_memory, ["app", "scripts"])

    Path.expand("Vagrantfile", path)
    |> File.write(template)
  end
end

