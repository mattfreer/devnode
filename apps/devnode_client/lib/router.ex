defmodule Devnode.Client.Router do
  alias Devnode.Client.ListRoute
  alias Devnode.Client.BuildRoute
  alias Devnode.Client.BuildRegistryRoute

  import Enum, only: [member?: 2]

  use Towel

  def execute({parsed_values, argv, _errors}) do
    f = match(argv)
    f.(parsed_values)
  end

  defp match(list) do
    cond do
      contains?(list, "list") -> &ListRoute.execute/1
      contains?(list, "build") -> &BuildRoute.execute/1
      contains?(list, "build-registry") -> &BuildRegistryRoute.execute/1

      true ->
        fn(_values) -> error("no match") end
    end
  end

  defp contains?(argv, target) when is_list(target) do
    Enum.all?(target, fn(t) ->
      Enum.member?(argv, t)
    end)
  end

  defp contains?(argv, target) do
    contains?(argv, [target])
  end
end
