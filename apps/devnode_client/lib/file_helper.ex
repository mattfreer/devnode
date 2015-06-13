defmodule Devnode.Client.FileHelper do
  def cwd do
    elem(File.cwd, 1)
  end
end

