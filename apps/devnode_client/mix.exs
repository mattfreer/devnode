defmodule Devnode.Client.Mixfile do
  use Mix.Project

  def project do
    [
      app: :devnode_client,
      version: "0.0.1",
      escript: escript,
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.0",
      deps: deps
    ]
  end

  defp escript do
    [main_module: Devnode.Client.CLI, embed_elixir: true]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :mix, :yamerl]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:devnode_core, in_umbrella: true},
      {:devnode_support, in_umbrella: true, only: [:test]},
      {:mock, "~> 0.1.0"},
      {:towel, "~> 0.2.1"},
      {:yamerl, github: "yakaz/yamerl"}
    ]
  end
end
