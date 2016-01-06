defmodule ImageRepoTest do
  use ExUnit.Case
  alias Devnode.Client.ImageRepo
  alias Devnode.Support.FakeImageRepo
  import Mock

  # called before each test is run
  setup do
    on_exit fn ->
      FakeImageRepo.remove
    end

    {:ok, image_repo: FakeImageRepo.build }
  end

  test "list returns images in repo", %{image_repo: image_repo} do
    assert ImageRepo.list(image_repo) == ["a_env", "c_env"]
  end

  test "#dir returns image repo path as defined in runtime config" do
    assert ImageRepo.dir == "/tmp/devnode_test/image_repo"
  end

  test "#dir returns image repo path as defined in env config, when runtime config doesn't exist" do
    with_mock Devnode.Client.RuntimeConfig, [:passthrough], [ exists?: fn -> false end] do
      assert ImageRepo.dir == "a/path/to/an/image/repo"
    end
  end
end

