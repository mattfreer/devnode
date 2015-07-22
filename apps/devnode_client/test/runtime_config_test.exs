defmodule Devnode.Client.RuntimeConfigTest do
  use ExUnit.Case
  alias Devnode.Client.RuntimeConfig

  test "path" do
    assert RuntimeConfig.path == Path.expand("support/files/dot_devnoderc.eex", __DIR__)
  end

  test "load config" do
    assert RuntimeConfig.load(RuntimeConfig.path) == [{
      'image_repo', [
        {'path', '/tmp/devnode_test/image_repo'}
      ]
    }]
  end

  test "image_repo_path" do
    assert RuntimeConfig.image_repo_path == "/tmp/devnode_test/image_repo"
  end

  test :exists? do
    assert RuntimeConfig.exists? == true
    assert RuntimeConfig.exists?(RuntimeConfig.path) == true
    assert RuntimeConfig.exists?("/bad/file/path") == false
  end
end

