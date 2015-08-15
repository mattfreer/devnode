defmodule Devnode.Client.ScaffoldMixin do
  @moduledoc """
  This module is a mixin to be used for modules that need to scaffold
  directory structures.

  Modules that use this mixin, should override the following functions:

  * tasks/2: return a list of MFA tuples representing scaffold
  operations that can be run in parallel.

  * sub_dirs/0: return a list names for directories that should be
  created.
  """

  defmacro __using__(_opts) do
    quote do
      def build(path, credentials) do
        create_dirs(path)

        _ = tasks(path, credentials)
        |> Enum.map(&apply_async/1)
        |> Enum.map(&Task.await/1)

        credentials
      end

      defp apply_async({m, f, a}) do
        Task.async(fn -> apply(m, f, a) end)
      end

      defp sub_dirs do
        []
      end

      defp tasks(path, credentials) do
        []
      end

      defp create_dirs(path) do
        Enum.each(sub_dirs, fn(d) ->
          File.mkdir_p("#{path}/#{d}")
        end)
      end

      defoverridable [tasks: 2, sub_dirs: 0]
    end
  end
end
