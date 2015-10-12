defmodule Devnode.Monitor.Node do
  @type t :: %__MODULE__{name: String.t, ip: String.t, port: String.t, image: String.t}

  defstruct name: "", ip: "", port: "", image: ""
end

