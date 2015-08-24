use Mix.Config

defmodule ConfigHelper do
  def tmp_dir do
    Path.expand("devnode_test", System.tmp_dir())
  end
end

config :paths, [
  image_repo: Path.expand("devnode_test/image_repo", System.tmp_dir),
  registry: Path.expand("devnode_test/registry", System.tmp_dir),
  runtime_config: Path.expand("../test/support/files/dot_devnoderc.eex", __DIR__)
]
