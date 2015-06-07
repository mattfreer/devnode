defmodule Devnode.CLI.Test do
  use ExUnit.Case

  # called before each test is run
  setup do
    on_exit fn ->
    end

    :ok
  end

  test "with arguments it returns ok" do
    argv = ["foo"]
    assert Devnode.Client.CLI.main(argv) == {:ok}
  end
end

