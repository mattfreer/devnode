defmodule Devnode.Client.Support.FakeImageRepo do
  alias Devnode.Client.Support.TestDir, as: TestDir

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
    registry_path = TestDir.mk_sub_dir("registry")

    Enum.each(images, fn(i) ->
      add_dir(registry_path, i) |> add_file("Dockerfile")
    end)

    Enum.each(non_images, fn(i) ->
      add_dir(registry_path, i)
    end)

    registry_path
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

