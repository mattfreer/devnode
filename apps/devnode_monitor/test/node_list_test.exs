defmodule Devnode.Monitor.NodeListTest do
  use ExUnit.Case
  alias Devnode.Monitor.NodeList, as: NodeList

  test "adding nodes" do
    list = NodeList.new()
    |> NodeList.add_entry(%{name: "foo", image: "a"})
    |> NodeList.add_entry(%{name: "bar", image: "b"})
    |> NodeList.add_entry(%{name: "baz", image: "c"})

    assert NodeList.get(list, "foo") == %{image: "a", name: "foo", ip: "192.168.124.1"}
    assert NodeList.get(list, "bar") == %{image: "b", name: "bar", ip: "192.168.124.2"}
    assert NodeList.get(list, "baz") == %{image: "c", name: "baz", ip: "192.168.124.3"}
  end

  test "node names must be unique" do
    list = NodeList.new()
    |> NodeList.add_entry(%{name: "foo"})

    assert NodeList.add_entry(list, %{name: "foo"}) == {:error, "node names must be unique, foo is already in use"}
  end
end
