defmodule Devnode.Client.Scaffold do
  require EEx

  @vm_memory 1024
  @registry "192.168.10.10:5000"

  EEx.function_from_file(
    :def,
    :vagrantfile_template,
    "lib/templates/vagrant_file.eex",
    [:ip, :memory, :shared_dirs]
  )

  EEx.function_from_file(
    :def,
    :docker_setup_template,
    "lib/templates/docker_setup.eex",
    [:registry]
  )

  EEx.function_from_file(
    :def,
    :fig_template,
    "lib/templates/fig.eex",
    [:image, :registry, :shared_dirs]
  )

  def build(path, name, image) do
    credentials = Devnode.Client.Node.new(name, image)
    create_dirs(path)

    env_path(path) |> copy_static_files
    env_path(path) |> create_vagrantfile(credentials)
    scripts_path(path) |> create_fig_config(credentials)
    recipes_path(path) |> create_docker_setup

    credentials
  end

  defp create_dirs(path) do
    Enum.each(["app", "scripts", "env/recipes"], fn(d) ->
      File.mkdir_p("#{path}/#{d}")
    end)
  end

  defp env_path(project_path) do
    project_path <> "/env"
  end

  defp scripts_path(project_path) do
    project_path <> "/scripts"
  end

  defp recipes_path(path) do
    path <> "/env/recipes"
  end

  defp create_vagrantfile(path, credentials) do
    template = credentials
    |> Map.get(:ip)
    |> vagrantfile_template(@vm_memory, ["app", "scripts"])

    file = path <> "/Vagrantfile"
    File.write(file, template)
  end

  defp create_fig_config(path, credentials) do
    template = credentials
    |> Map.get(:image)
    |> fig_template(@registry, ["app", "scripts"])

    File.write(Path.expand("fig.yml", path), template)
  end

  defp create_docker_setup(path) do
    file = path <> "/docker_setup.sh"
    File.write(file, docker_setup_template(@registry))
  end

  defp copy_static_files(path) do
    File.copy("lib/templates/bootstrap.sh", path <> "/bootstrap.sh")
  end
end
