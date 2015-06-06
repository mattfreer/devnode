defmodule Devnode.Monitor do
  use Application

  def start(_type, _state) do
    Devnode.Monitor.NodeServerSupervisor.start_link(%{})
  end
end
