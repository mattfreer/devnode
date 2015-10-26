defmodule Devnode.Client.Router do
  alias Devnode.Client.ListRoute
  alias Devnode.Client.BuildRoute
  alias Devnode.Client.BuildRegistryRoute

  import Enum, only: [member?: 2]

  use Towel

  def execute(options) do
    f = elem(options, 1) |> match
    f.(elem(options, 0))
  end

  def match(list) do
    cond do
      member?(list, "list") -> &ListRoute.execute/1
      member?(list, "build") -> &BuildRoute.execute/1
      member?(list, "build-registry") -> &BuildRegistryRoute.execute/1

      true ->
        fn(_values) -> error("no match") end
    end
  end
end
