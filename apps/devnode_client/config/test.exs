use Mix.Config

defmodule ConfigHelper do
  def tmp_dir do
    Path.expand("devnode_test", System.tmp_dir())
  end
end

config :paths, [
  image_repo: Path.expand("image_repo", ConfigHelper.tmp_dir)
]
