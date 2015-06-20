defmodule Devnode.Monitor.NodeStash do

  def exists? do
    File.exists?(file) && has_content?
  end

  def write(data, f \\ file) do
    unless exists? do
      File.mkdir_p Path.dirname(f)
    end
    File.write(f, "#{ :erlang.term_to_binary(data) }")
  end

  def read(f \\ file) do
    if exists? do
      file_content(f)
      |> :erlang.binary_to_term
      |> response
    else
      {:error, "no stash present"}
    end
  end

  def purge(f \\ file) do
     File.rm(f)
  end

  def file do
    Application.get_env(:paths, :stash)
  end

  defp response(value) do
    {:ok, value}
  end

  defp file_content(f \\ file) do
    File.read!(f) |> String.rstrip
  end

  defp has_content?(f \\ file) do
    (file_content(f) |> String.length) > 0
  end
end
