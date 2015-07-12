defmodule Devnode.Client.ImageRepo do

  def dir do
    Application.get_env(:paths, :image_repo)
  end

  def list(dir) do
    file_list(dir)
    |> Enum.map(fn(item) -> to_map(item, dir) end)
    |> Enum.filter(&is_docker_image?/1)
    |> Enum.map(fn(item) -> item.name end)
    |> Enum.sort
  end

  defp file_list(dir) do
    File.ls(dir) |> elem(1)
  end

  defp is_docker_image?(item) do
    case File.dir?(item.path) do
      true -> Enum.member?(file_list(item.path), "Dockerfile")
      false -> false
    end
  end

  defp to_map(name, path) do
    %{
      name: name,
      path: Path.expand(name, path)
    }
  end
end
