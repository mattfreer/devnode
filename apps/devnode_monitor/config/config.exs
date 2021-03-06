# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

config :devnode_monitor, :paths, %{
  stash: Path.expand("devnode/node_stash", System.tmp_dir)
}

if Path.expand("#{Mix.env}.exs", __DIR__) |> File.exists? do
  import_config "#{Mix.env}.exs"
end
