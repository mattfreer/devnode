defmodule Devnode.Client.Scaffold do
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
    Path.expand("env", project_path)
  end

  defp scripts_path(project_path) do
    Path.expand("scripts", project_path)
  end

  defp recipes_path(project_path) do
    Path.expand("env/recipes", project_path)
  end

  defp create_vagrantfile(path, credentials) do
    template = credentials
    |> Map.get(:ip)
    |> vagrantfile_template(@vm_memory, ["app", "scripts"])

    Path.expand("Vagrantfile", path)
    |> File.write(template)
  end

  defp create_fig_config(path, credentials) do
    template = credentials
    |> Map.get(:image)
    |> fig_template(@registry, ["app", "scripts"])

    Path.expand("fig.yml", path)
    |> File.write(template)
  end

  defp create_docker_setup(path) do
    Path.expand("docker_setup.sh", path)
    |> File.write(docker_setup_template(@registry))
  end

  defp copy_static_files(path) do
    File.copy("lib/templates/bootstrap.sh", Path.expand("bootstrap.sh", path))
  end
end
