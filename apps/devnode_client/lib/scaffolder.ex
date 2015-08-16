defmodule Devnode.Client.Scaffolder do
  @moduledoc """
  A custom behaviour for Modules that provide scaffolding (typically
  modules that use the `ScaffoldMixin`).

  Modules adopting this behaviour will have to implement all the
  functions defined with defcallback.
  """

  use Behaviour

  @doc """
  returns a list of tuples representing scaffold operations that should
  be run in parallel. The tuples should be in the format:
  {module, function, [arguments]}
  """
  defcallback tasks(String.t, %{}) :: [{atom, atom, [any]}]
end

