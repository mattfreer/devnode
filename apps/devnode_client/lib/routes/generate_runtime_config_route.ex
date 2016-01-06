defmodule Devnode.Client.GenerateRuntimeConfigRoute do
  alias Devnode.Client.FileHelper
  alias Devnode.Client.RuntimeConfigScaffold
  alias Devnode.Client.ImageRepo
  alias Devnode.Client.RouteValidation
  alias Devnode.Types

  use Towel

  @spec execute(Keyword.t) :: Types.result_monad
  def execute(values) do
    validations = [
      &ImageRepo.exists?/0
    ]

    RouteValidation.validate(validations)
    |> scaffold_runtime_config
    |> summary
  end

  @spec scaffold_runtime_config(Types.result_monad) :: Types.result_monad
  defp scaffold_runtime_config(result) do
    bind(result, fn(r) ->
      RuntimeConfigScaffold.build(FileHelper.cwd, %{image_repo: ImageRepo.dir})
    end)
  end

  @spec summary(Types.result_monad) :: Types.result_monad
  defp summary(result) do
    bind(result, fn(r) ->
      Result.wrap("The `devnoderc` file has been created in the current/working directory")
    end)
  end
end

