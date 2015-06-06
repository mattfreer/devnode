defmodule Devnode.Monitor.NodeServerSupervisor do
  use Supervisor

  # A convenience to start the supervisor
  def start_link(state) do
    :supervisor.start_link(__MODULE__, state)
  end

  # The callback invoked when the supervisor starts
  def init(state) do
    children = [
      worker(Devnode.Monitor.NodeServer, [])
    ]
    supervise children, strategy: :one_for_one
  end
end
