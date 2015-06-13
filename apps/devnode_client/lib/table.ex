# Soloution provided by Patrick Oscity
# http://stackoverflow.com/questions/30749400/output-tabular-data-with-io-ansi

defmodule Table do
  def format(rows, opts \\ [])
  def format([] = rows, opts) do
    ""
  end
  def format([_head|_tail] = rows, opts) do
    padding = Keyword.get(opts, :padding, 1)
    rows = stringify(rows)
    widths = rows |> transpose |> column_widths
    rows |> pad_cells(widths, padding) |> join_rows
  end

  defp pad_cells(rows, widths, padding) do
    Enum.map rows, fn row ->
      for {val, width} <- Enum.zip(row, widths) do
        String.ljust(val, width + padding)
      end
    end
  end

  def join_rows(rows) do
    rows |> Enum.map(&Enum.join/1) |> Enum.join("\n")
  end

  defp stringify(rows) do
    Enum.map rows, fn row ->
      Enum.map(row, &to_string/1)
    end
  end

  defp column_widths(columns) do
    Enum.map columns, fn column ->
      column |> Enum.map(&String.length/1) |> Enum.max
    end
  end

  # http://stackoverflow.com/questions/23705074
  defp transpose([[]|_]), do: []
  defp transpose(rows) do
    [Enum.map(rows, &hd/1) | transpose(Enum.map(rows, &tl/1))]
  end
end
