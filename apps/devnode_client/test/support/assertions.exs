defmodule Devnode.Client.Support.Assertions do
  use ExUnit.Case

  def assert_file_content(content, support_file) do
    file = Path.expand(support_file, "test/support/files")
    assert String.rstrip(content) == File.read!(file) |> String.rstrip
  end
end
