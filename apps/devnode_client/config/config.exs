# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

config :devnode_client, paths: %{
  image_repo: Path.expand("devnode/image_repo", System.tmp_dir),
  registry: Path.expand("devnode/registry", System.tmp_dir)
}

config :devnode_client, :ips, %{
  registry: "192.168.10.10"
}

config :devnode_client, :ports, %{
  registry: "5000"
}

if Path.expand("#{Mix.env}.exs", __DIR__) |> File.exists? do
  import_config "#{Mix.env}.exs"
end
