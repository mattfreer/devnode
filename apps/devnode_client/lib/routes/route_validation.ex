defmodule Devnode.Client.RouteValidation do
  alias Devnode.Types

  use Towel

  @spec validate([]) :: Types.result_monad
  def validate(list) do
    case valid?(list) do
      {:ok, _} = result -> result
      {:error, failures} -> error(List.first(failures))
    end
  end

  @spec valid?([]) :: Types.result_monad
  defp valid?(validators) do
    failures = Enum.reduce(validators, [], fn(f, acc) ->
      case f.() do
        true -> acc
        false -> [stringify(f)|acc]
      end
    end)

    case Enum.empty?(failures) do
      true -> ok("valid")
      false -> Enum.reverse(failures) |> error
    end
  end

  @spec stringify(any) :: String.t
  defp stringify(f) do
    Macro.to_string(quote do: unquote(f)) |> String.lstrip(?&)
  end
end

