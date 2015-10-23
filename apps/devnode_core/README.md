# DevnodeCore

This application contains core utilities that are utilised in
other apps within the umbrella project.

Other apps that wish utilise the modules within this app, should add it
as as test dependency within the `mix.exs` file:

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add devnode_core to your list of dependencies in `mix.exs`:

        def deps do
          [{:devnode_core, "~> 0.0.1"}]
        end

  2. Ensure devnode_core is started before your application:

        def application do
          [applications: [:devnode_core]]
        end
