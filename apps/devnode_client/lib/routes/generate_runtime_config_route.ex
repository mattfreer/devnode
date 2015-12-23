defmodule Devnode.Client.GenerateRuntimeConfigRoute do
  alias Devnode.Client.FileHelper
  alias Devnode.Client.RuntimeConfigScaffold
  alias Devnode.Client.ImageRepo
  alias Devnode.Types

  use Towel

  @spec execute(Keyword.t) :: Types.result_monad
  def execute(values) do
    scaffold_runtime_config
    #|> Map.values
    #|> Enum.map(fn(i) -> Map.from_struct(i) |> Map.values end)
    #|> Table.format(padding: 4)

    ok("done")
  end

  defp scaffold_runtime_config() do
    RuntimeConfigScaffold.build(FileHelper.cwd, %{image_repo: ImageRepo.dir})
  end
end

