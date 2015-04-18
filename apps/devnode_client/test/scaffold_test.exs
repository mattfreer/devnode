defmodule Devnode.Client.ScaffoldTest do
  use ExUnit.Case
  alias Devnode.Client.Support.TestDir, as: TestDir
  alias Devnode.Client.Scaffold, as: Scaffold
  import Devnode.Client.Support.Assertions

  setup do
    path = TestDir.mk_sub_dir("a")

    on_exit fn ->
      TestDir.remove
    end

    {:ok, project_path: path}
  end

  test "it creates a app folder in the project path", %{project_path: project_path} do
    dir = project_path <> "/app"

    Scaffold.build(project_path)
    assert File.dir?(dir) == true
  end

  test "it creates a env folder in the project path", %{project_path: project_path} do
    dir = project_path <> "/env"

    Scaffold.build(project_path)
    assert File.dir?(dir) == true
  end

  test "it creates a Vagrantfile in the env directory", %{project_path: project_path} do
    file = project_path <> "/env/Vagrantfile"
    Scaffold.build(project_path)
    assert File.exists?(file) == true
  end

  test "it creates a Vagrantfile with expected content", %{project_path: project_path} do
    file = project_path <> "/env/Vagrantfile"
    Scaffold.build(project_path)
    assert_file_content(File.read(file) |> elem(1), "vagrant_file.txt")
  end

  test "it creates a bootstrap.sh file in the env directory", %{project_path: project_path} do
    file = project_path <> "/env/bootstrap.sh"
    Scaffold.build(project_path)
    assert File.exists?(file) == true
  end

  test "it creates a docker_setup.sh file in the env/recipes directory", %{project_path: project_path} do
    file = project_path <> "/env/recipes/docker_setup.sh"
    Scaffold.build(project_path)
    assert File.exists?(file) == true
  end

  test "it creates a docker_setup.sh file in env/recipes directory with expected content", %{project_path: project_path} do
    file = project_path <> "/env/recipes/docker_setup.sh"
    Scaffold.build(project_path)
    assert_file_content(File.read(file) |> elem(1), "docker_setup.txt")
  end
end
