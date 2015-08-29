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
      ip: Application.get_env(:ips, :registry),
    }

    path = Application.get_env(:paths, :registry)
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
    assert File.ls(dir) |> elem(1) == ["b_env", "a_env", ".dot_file", "c_env"]
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
    expected = RegistryScaffold.build(path, credentials)
    {:error, fun} = expected
    assert_raise(RegistryExistsError, fun)
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

