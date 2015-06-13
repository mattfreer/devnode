defmodule Devnode.CLI.Test do
  use ExUnit.Case
  import Mock

  # called before each test is run
  setup do
    on_exit fn ->
      Devnode.Client.stop
    end

    nodes = Enum.into [
      foo: %{ip: "192.169.100.100", name: "foo"},
      bar: %{ip: "192.169.100.101", name: "bar"}
    ], HashDict.new

    {:ok, nodes: nodes}
  end

  test "with non matched arguments it returns no match" do
    argv = ["foo"]
    assert Devnode.Client.CLI.main(argv) == "no match"
  end

  test "list returns an empty string, when no nodes are registered" do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> HashDict.new end] do
      argv = ["list"]
      assert Devnode.Client.CLI.main(argv) == ""
    end
  end

  test "list returns an table of nodes, when nodes are registered", %{nodes: nodes} do
    with_mock Devnode.Client.Node, [:passthrough], [list: fn -> nodes end] do
      argv = ["list"]
      expected = "192.169.100.100    foo    \n192.169.100.101    bar    "
      assert Devnode.Client.CLI.main(argv) == expected
    end
  end
end

