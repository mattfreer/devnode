defmodule Devnode.Client.ScaffoldMixin do
  @moduledoc """
  This module is a mixin to be used for modules that need to scaffold
  directory structures.

  The `ScaffoldMixin` module adopts the `Scaffolder` behaviour. But
  it doesn't implement the requiered `tasks/2` function its self. Rather
  this is a requirement for modules that use the `ScaffoldMixin`.

  Modules that use this mixin, can override the following functions:

  * valid?/2: validate that the build should commence. Called from
  `build/2`.

  * sub_dirs/0: return a list of names for directories that should be
  created. Called from `build/2`.
  """

  defmacro __using__(_opts) do
    quote do
      @behaviour Devnode.Client.Scaffolder

      @spec build(String.t, map) :: tuple
      def build(path, credentials) do
        case valid?(path, credentials) do
          {:error, callback} = e -> e
          {:ok, _} -> {:ok, start_build(path, credentials)}
        end
      end

      defp start_build(path, credentials) do
        _ = create_dirs(path)

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

      defp create_dirs(path) do
        Enum.each(sub_dirs, fn(d) ->
          File.mkdir_p("#{path}/#{d}")
        end)
      end

      defoverridable [sub_dirs: 0]
    end
  end
end
