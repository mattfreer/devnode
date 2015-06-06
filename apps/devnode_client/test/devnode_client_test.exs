defmodule Devnode.ClientTest do
  use ExUnit.Case
  import Mock

  setup do
    on_exit fn ->
      Devnode.Client.stop
    end
    :ok
  end

  test "#start converts the BEAM instance into a Node" do
    with_mock Devnode.Client, [:passthrough], [client_name: fn -> :"foo@bar" end] do
      assert Node.self == :nonode@nohost
      Devnode.Client.start
      assert Node.self == :"foo@bar"
    end
  end

  test "#start connects to monitor node" do
    with_mock Devnode.Client, [:passthrough], [client_name: fn -> :"foo@bar" end] do
      with_mock Node, [:passthrough], [connect: fn(node) -> true end] do
        Devnode.Client.start
        assert called Node.connect(:"dnmonitor@127.0.0.1")
      end
    end
  end

  test "#stop turns the node into a non-distributed node" do
    with_mock Devnode.Client, [:passthrough], [client_name: fn -> :"foo@bar" end] do
      assert Node.self == :"nonode@nohost"
      Devnode.Client.start
      assert Node.self == :"foo@bar"
      Devnode.Client.stop
      :timer.sleep(500)
      assert Node.self == :"nonode@nohost"
    end
  end
end
