defmodule Devnode.CLI.Test do
  use ExUnit.Case
  alias Devnode.Client.Support.TestDir, as: TestDir
  import Devnode.Client.Support.Assertions
  import Mock

  # called before each test is run
  setup do
    on_exit fn ->
      Devnode.Client.stop
      TestDir.remove
    end

    test_project = %{
      path: TestDir.mk_sub_dir("a")
    }

    nodes = Enum.into [
      foo: %{ip: "192.169.100.100", name: "foo"},
      bar: %{ip: "192.169.100.101", name: "bar"}
    ], HashDict.new

    {:ok, nodes: nodes, test_project: test_project}
  end

  defp with_build_mocks(options, fun) do
    with_mock Devnode.Client.FileHelper, [:passthrough], [
      cwd: fn -> Map.get(options.project, :path) end] do

      with_mock Devnode.Client.Node, [:passthrough], [
        new: fn(name) -> %{name: name, ip: "192.100.100.100"} end] do

        fun.()
      end
    end
  end

  defp file_content(project, file_path) do
    File.read(project.path <> file_path) |> elem(1)
  end

  test "with non matched arguments it returns no match" do
    argv = ["foo"]
    assert Devnode.Client.CLI.main(argv) == "no match"
  end

  test "list returns an empty string, when no nodes are registered" do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> HashDict.new end] do
      argv = ["list"]
      assert Devnode.Client.CLI.main(argv) == ""
    end
  end

  test "list returns an table of nodes, when nodes are registered", %{nodes: nodes} do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> nodes end] do
      argv = ["list"]
      expected = "192.169.100.100    foo    \n192.169.100.101    bar    "
      assert Devnode.Client.CLI.main(argv) == expected
    end
  end

  test "build returns new node credentials", %{test_project: project} do
    with_build_mocks(%{project: project}, fn ->
      argv = ["build", "-n=my_node_name"]
      expected = "192.100.100.100    my_node_name"
      assert Devnode.Client.CLI.main(argv) == expected
    end)
  end

  test "build scaffolds project", %{test_project: project} do
    with_build_mocks(%{project: project}, fn ->
      argv = ["build", "-n=my_node_name"]
      Devnode.Client.CLI.main(argv)

      assert File.dir?(project.path <> "/app") == true
      assert File.dir?(project.path <> "/env") == true
      assert File.exists?(project.path <> "/env/bootstrap.sh") == true

      file_content(project, "/env/Vagrantfile")
      |> assert_file_content("vagrant_file.txt")

      file_content(project, "/env/recipes/docker_setup.sh")
      |> assert_file_content("docker_setup.txt")
    end)
  end
end

