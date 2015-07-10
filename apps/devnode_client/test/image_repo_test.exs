defmodule ImageRepoTest do
  use ExUnit.Case
  alias Devnode.Client.ImageRepo
  alias Devnode.Support.TestDir
  alias Devnode.Support.FakeImageRepo

  # called before each test is run
  setup do
    on_exit fn ->
      TestDir.remove
    end

    {:ok, image_repo: FakeImageRepo.build }
  end


  test "list returns images in repo", %{image_repo: image_repo} do
    assert ImageRepo.list(image_repo) == ["a_env", "c_env"]
  end
end

