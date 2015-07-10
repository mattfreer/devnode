defmodule Devnode.Client.ScaffoldTest do
  use ExUnit.Case
  alias Devnode.Support.TestDir, as: TestDir
  alias Devnode.Client.Scaffold, as: Scaffold
  import Devnode.Client.Support.Assertions
  import Mock

  setup do
    on_exit fn ->
      TestDir.remove
    end

    test_project = %{
      path: TestDir.mk_sub_dir("a"),
      name: "test project",
      image: "a_env"
    }

    {:ok, project: test_project}
  end

  def with_node_mock(fun) do
    with_mock Devnode.Client.Node, [:passthrough], [
      new: fn(name, image) -> %{ image: "selected_image", name: "my node", ip: "192.100.100.100" } end] do
      fun.()
    end
  end

  test "#build returns node credentials Map", %{project: project} do
    with_node_mock(fn() ->
      expected = Scaffold.build(project.path, project.name, project.image)
      assert expected == %{image: "selected_image", ip: "192.100.100.100", name: "my node"}
    end)
  end

  test "#build creates a app folder in the project path", %{project: project} do
    with_node_mock(fn() ->
      dir = project.path <> "/app"
      Scaffold.build(project.path, project.name, project.image)
      assert File.dir?(dir) == true
    end)
  end

  test "#build creates a env folder in the project path", %{project: project} do
    with_node_mock(fn() ->
      dir = project.path <> "/env"

      Scaffold.build(project.path, project.name, project.image)
      assert File.dir?(dir) == true
    end)
  end

  test "#build creates a Vagrantfile in the env directory", %{project: project} do
    with_node_mock(fn() ->
      file = project.path <> "/env/Vagrantfile"
      Scaffold.build(project.path, project.name, project.image)
      assert File.exists?(file) == true
    end)
  end

  test "#build creates a Vagrantfile with expected content", %{project: project} do
    with_node_mock(fn() ->
      file = project.path <> "/env/Vagrantfile"
      Scaffold.build(project.path, project.name, project.image)
      assert_file_content(File.read(file) |> elem(1), "vagrant_file.txt")
    end)
  end

  test "#build creates a bootstrap.sh file in the env directory", %{project: project} do
    with_node_mock(fn() ->
      file = project.path <> "/env/bootstrap.sh"
      Scaffold.build(project.path, project.name, project.image)
      assert File.exists?(file) == true
    end)
  end

  test "#build creates a docker_setup.sh file in the env/recipes directory", %{project: project} do
    with_node_mock(fn() ->
      file = project.path <> "/env/recipes/docker_setup.sh"
      Scaffold.build(project.path, project.name, project.image)
      assert File.exists?(file) == true
    end)
  end

  test "#build creates a docker_setup.sh file in env/recipes directory with expected content", %{project: project} do
    with_node_mock(fn() ->
      file = project.path <> "/env/recipes/docker_setup.sh"
      Scaffold.build(project.path, project.name, project.image)
      assert_file_content(File.read(file) |> elem(1), "docker_setup.txt")
    end)
  end
end
