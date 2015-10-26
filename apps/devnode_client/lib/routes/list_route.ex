defmodule Devnode.Client.ListRoute do
  alias Devnode.Client.NodeServerProxy
  alias Devnode.Types

  use Towel

  @spec execute(Keyword.t) :: Types.result_monad
  def execute(_values) do
    result = NodeServerProxy.list
    |> Map.values
    |> Enum.map(fn(i) -> Map.from_struct(i) |> Map.values end)
    |> Table.format(padding: 4)

    ok(result)
  end
end

