defmodule Devnode.CLI.Test do
  use ExUnit.Case
  alias Devnode.Support.TestDir
  alias Devnode.Support.FakeImageRepo
  alias Devnode.Client.ImageRepo
  import Devnode.Client.Support.Assertions
  import Mock

  # called before each test is run
  setup do
    on_exit fn ->
      Devnode.Client.stop
      FakeImageRepo.remove
      TestDir.remove
    end

    test_project = %{
      path: TestDir.mk_sub_dir("a")
    }

    nodes = Enum.into [
      foo: %Devnode.Node{image: "a_env", ip: "192.169.100.100", name: "foo", port: "7001"},
      bar: %Devnode.Node{image: "c_env", ip: "192.169.100.101", name: "bar", port: "7002"}
    ], Map.new

    FakeImageRepo.build

    {
      :ok,
      nodes: nodes,
      test_project: test_project
    }
  end

  defp with_build_mocks(options, fun) do
    with_mock Devnode.Client.FileHelper, [:passthrough], [
      cwd: fn -> Map.get(options.project, :path) end] do

      with_mock Devnode.Client.Node, [:passthrough], [
        new: fn(%{image: image, name: name}) -> %{image: image, name: name, ip: "192.100.100.100", port: "7001"} end] do

        with_mock IO, [:passthrough], [ gets: fn(msg) -> options.image end] do
          fun.()
        end
      end
    end
  end

  defp file_content(path) do
    File.read(path) |> elem(1)
  end

  test "with non matched arguments it returns no match" do
    argv = ["foo"]
    assert Devnode.Client.CLI.main(argv) == "The `foo` command has not been recognised\n"
  end

  test "list returns an empty string, when no nodes are registered" do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> Map.new end] do
      argv = ["list"]
      assert Devnode.Client.CLI.main(argv) == ""
    end
  end

  test "list returns an table of nodes, when nodes are registered", %{nodes: nodes} do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> nodes end] do
      argv = ["list"]
      assert Devnode.Client.CLI.main(argv) ==
      "c_env    192.169.100.101    bar    7002    \na_env    192.169.100.100    foo    7001    "
    end
  end

  test "build returns help content if no name is specfied", %{test_project: project} do
    with_build_mocks(%{project: project, image: ""}, fn ->
      argv = ["build"]
      assert Devnode.Client.CLI.main(argv) ==
      "Requires `--name` option.\nThe `build` command should be used as follows:\nbuild --name=node_name\n\n"
    end)
  end

  test "build returns help content if no image is specfied", %{test_project: project} do
    with_build_mocks(%{project: project, image: ""}, fn ->
      argv = ["build", "-n=my_node_name"]
      assert Devnode.Client.CLI.main(argv) ==
      "No image specified.\nThe `build` command should be used as follows:\nbuild --name=node_name\n\n"
    end)
  end

  test "build requires runtime config" do
    with_mock Devnode.Client.RuntimeConfig, [:passthrough], [ exists?: fn -> false end] do
      argv = ["build", "-n=my_node_name"]
      assert Devnode.Client.CLI.main(argv) ==
      "The `build` command requires a `.devnoderc` config file to be present in the current working directory\n"
    end
  end

  test "build returns new node credentials, when valid image is selected", %{test_project: project} do
    with_build_mocks(%{project: project, image: "a_env"}, fn ->
      argv = ["build", "-n=my_node_name"]
      expected = "a_env    192.100.100.100    7001    my_node_name"
      assert Devnode.Client.CLI.main(argv) == expected
    end)
  end

  test "build returns help content if invalid image is selected", %{test_project: project} do
    with_build_mocks(%{project: project, image: "invalid"}, fn ->
      argv = ["build", "-n=my_node_name"]
      assert Devnode.Client.CLI.main(argv) ==
      "The image named 'invalid', is not available.\nThe `build` command should be used as follows:\nbuild --name=node_name\n\n"
    end)
  end

  test "build scaffolds project, when valid image is selected", %{test_project: project} do
    with_build_mocks(%{project: project, image: "c_env"}, fn ->
      argv = ["build", "-n=my_node_name"]
      Devnode.Client.CLI.main(argv)

      assert File.dir?(project.path <> "/app") == true
      assert File.dir?(project.path <> "/env") == true
      assert File.exists?(project.path <> "/env/bootstrap.sh") == true

      file_content(Path.expand("env/Vagrantfile", project.path))
      |> assert_file_content("vagrant_file.txt")

      file_content(Path.expand("env/recipes/docker_setup.sh", project.path))
      |> assert_file_content("docker_setup.txt")

      file_content(Path.expand("scripts/fig.yml", project.path))
      |> assert_file_content("fig.txt")
    end)
  end

  test "build doesn't scaffold the project, when invalid image is selected", %{test_project: project} do
    with_build_mocks(%{project: project, image: "invalid"}, fn ->
      argv = ["build", "-n=my_node_name"]
      Devnode.Client.CLI.main(argv)

      assert File.dir?(project.path <> "/app") == false
      assert File.dir?(project.path <> "/env") == false
    end)
  end

  test "build-registry returns new node credentials" do
    argv = ["build-registry"]
    expected = "192.168.10.10    registry"
    assert Devnode.Client.CLI.main(argv) == expected
  end

  test "build-registry scaffolds registry" do
    argv = ["build-registry"]
    Devnode.Client.CLI.main(argv)

    registry_path = Application.get_env(:devnode_client, :paths) |> Map.get(:registry)

    assert File.dir?(Path.expand("app", registry_path)) == true
    assert File.dir?(Path.expand("env", registry_path)) == true
    assert File.dir?(Path.expand("scripts", registry_path)) == true

    assert File.ls(Path.expand("app", registry_path)) |> elem(1) |> Enum.sort== [".dot_file", "a_env", "b_env", "c_env"]
    assert File.exists?(Path.expand("env/bootstrap.sh", registry_path)) == true

    file_content(Path.expand("env/Vagrantfile", registry_path))
    |> assert_file_content("registry_vagrant_file.txt")
  end

  test "when registry exists, build-registry returns help content", %{test_project: project} do
    File.mkdir_p(Application.get_env(:devnode_client, :paths) |> Map.get(:registry))
    argv = ["build-registry"]
    assert Devnode.Client.CLI.main(argv) == "The `build-registry` command will only replace an existing registry if the `--force` option is specified\n"
  end

  test "when registry exists, build-registry replaces registry, if `force` option is specified", %{test_project: project} do
    File.mkdir_p(Application.get_env(:devnode_client, :paths) |> Map.get(:registry))
    argv = ["build-registry", "-f"]

    expected = "192.168.10.10    registry"
    assert Devnode.Client.CLI.main(argv) == expected
  end
end

