use Mix.Config

defmodule ConfigHelper do
  def tmp_dir do
    Path.expand("devnode_test", System.tmp_dir())
  end
end

config :paths, [
  stash: Path.expand("stash/node_stash", ConfigHelper.tmp_dir)
]
