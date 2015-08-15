defmodule Devnode.Client.ScaffoldTest do
  use ExUnit.Case
  alias Devnode.Support.TestDir, as: TestDir
  alias Devnode.Client.NodeScaffold, as: Scaffold
  import Devnode.Client.Support.Assertions

  setup do
    on_exit fn ->
      TestDir.remove
    end

    node_credentials = %{
      name: "test project",
      image: "a_env",
      ip: "192.100.100.100"
    }

    {
      :ok,
      node_credentials: node_credentials,
      path: TestDir.mk_sub_dir("a")
    }
  end

  test "#build returns node credentials Map", %{path: path, node_credentials: node_credentials} do
    expected = Scaffold.build(path, node_credentials)
    assert expected == %{image: "a_env", ip: "192.100.100.100", name: "test project"}
  end

  test "#build creates a app folder in the project path", %{path: path, node_credentials: node_credentials} do
    dir = Path.expand("app", path)
    Scaffold.build(path, node_credentials)
    assert File.dir?(dir) == true
  end

  test "#build creates a env folder in the project path", %{path: path, node_credentials: node_credentials} do
    dir = Path.expand("env", path)

    Scaffold.build(path, node_credentials)
    assert File.dir?(dir) == true
  end

  test "#build creates a Vagrantfile in the env directory", %{path: path, node_credentials: node_credentials} do
    file = Path.expand("env/Vagrantfile", path)
    Scaffold.build(path, node_credentials)
    assert File.exists?(file) == true
  end

  test "#build creates a Vagrantfile with expected content", %{path: path, node_credentials: node_credentials} do
    file = Path.expand("env/Vagrantfile", path)
    Scaffold.build(path, node_credentials)
    assert_file_content(File.read(file) |> elem(1), "vagrant_file.txt")
  end

  test "#build creates a bootstrap.sh file in the env directory", %{path: path, node_credentials: node_credentials} do
    file = Path.expand("env/bootstrap.sh", path)
    Scaffold.build(path, node_credentials)
    assert File.exists?(file) == true
  end

  test "#build creates a docker_setup.sh file in the env/recipes directory", %{path: path, node_credentials: node_credentials} do
    file = Path.expand("env/recipes/docker_setup.sh", path)
    Scaffold.build(path, node_credentials)
    assert File.exists?(file) == true
  end

  test "#build creates a docker_setup.sh file in env/recipes directory with expected content", %{path: path, node_credentials: node_credentials} do
    file = Path.expand("env/recipes/docker_setup.sh", path)
    Scaffold.build(path, node_credentials)
    assert_file_content(File.read(file) |> elem(1), "docker_setup.txt")
  end
end
