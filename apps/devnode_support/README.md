#Devnode.Support
===============

This application contains a number of test helpers that are utilised in
other apps within the umbrella project.

Other apps that wish utilise the modules within this app, should add it
as as test dependency within the `mix.exs` file:

```elixir
  defp deps do
    [
      {:devnode_support, in_umbrella: true, only: [:test]}
    ]
  end
```
