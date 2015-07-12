defmodule Devnode.Support.FakeImageRepo do

  @defaults [
    images: ["a_env", "c_env"],
    non_images: ["b_env", ".dot_file"]
  ]

  def build() do
    build(
      Keyword.get(@defaults, :images),
      Keyword.get(@defaults, :non_images)
    )
  end

  def build(images, non_images \\ []) do
    Enum.each(images, fn(i) ->
      add_dir(image_repo_path, i) |> add_file("Dockerfile")
    end)

    Enum.each(non_images, fn(i) ->
      add_dir(image_repo_path, i)
    end)

    image_repo_path
  end

  def remove do
    File.rm_rf!(image_repo_path)
  end

  defp image_repo_path do
    Application.get_env(:paths, :image_repo)
  end

  defp add_dir(registry, file_path) do
    path = "#{ registry }/#{ file_path }"
    File.mkdir_p(path)
    path
  end

  defp add_file(registry, file_path) do
    File.touch("#{ registry }/#{ file_path }")
    registry
  end
end

