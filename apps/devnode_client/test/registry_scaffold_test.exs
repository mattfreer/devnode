defmodule Devnode.Client.RegistryScaffoldTest do
  use ExUnit.Case
  alias Devnode.Support.TestDir
  alias Devnode.Client.RegistryScaffold
  alias Devnode.Client.RegistryExistsError
  alias Devnode.Support.FakeImageRepo

  # called before each test is run
  setup do
    on_exit fn ->
      TestDir.remove
      FakeImageRepo.remove
    end

    credentials = %{
      name: "registry",
      ip: Application.get_env(:devnode_client, :ips) |> Map.get(:registry),
    }

    path = Application.get_env(:devnode_client, :paths) |> Map.get(:registry)
    FakeImageRepo.build

    {:ok, path: path, credentials: credentials}
  end

  test "#build returns credentials", %{path: path, credentials: credentials} do
    expected = RegistryScaffold.build(path, credentials)
    assert expected == {:ok, %{ip: "192.168.10.10", name: "registry"}}
  end

  test "#build symlinks an `app` dir to the image repo", %{path: path, credentials: credentials} do
    dir = Path.expand("app", path)
    RegistryScaffold.build(path, credentials)
    assert File.dir?(dir) == true
    assert File.ls(dir) |> elem(1) |> Enum.sort == [".dot_file", "a_env", "b_env", "c_env"]
  end

  test "#build creates an env folder", %{path: path, credentials: credentials} do
    dir = Path.expand("env", path)
    RegistryScaffold.build(path, credentials)
    assert File.dir?(dir) == true
  end

  test "#build creates a scripts folder", %{path: path, credentials: credentials} do
    dir = Path.expand("scripts", path)
    RegistryScaffold.build(path, credentials)
    assert File.dir?(dir) == true
  end

  test "#build creates a Vagrantfile in the env directory", %{path: path, credentials: credentials} do
    file = Path.expand("env/Vagrantfile", path)
    RegistryScaffold.build(path, credentials)
    assert File.exists?(file) == true
  end

  test "#build creates a bootstrap.sh file in the env directory", %{path: path, credentials: credentials} do
    file = Path.expand("env/bootstrap.sh", path)
    RegistryScaffold.build(path, credentials)
    assert File.exists?(file) == true
  end

  test "#when registry exists, build returns an error", %{path: path, credentials: credentials} do
    File.mkdir_p(path)

    assert RegistryScaffold.build(path, credentials) == {:error, "Registry already exists"}
  end

  test "#when registry exists and override is false, build returns an error", %{path: path, credentials: credentials} do
    File.mkdir_p(path)
    expected = RegistryScaffold.build(path, Map.put(credentials, :override, false))
    {:error, _fun} = expected
  end

  test "when registry exists and overriding, build returns credentials", %{path: path, credentials: credentials} do
    File.mkdir_p(path)
    expected = RegistryScaffold.build(path, Map.put(credentials, :override, true))
    assert expected == {:ok, %{ip: "192.168.10.10", name: "registry", override: true}}
  end
end

