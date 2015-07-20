defmodule Devnode.Client.RuntimeConfig do
  def path do
    case Application.get_env(:paths, :runtime_config) do
      nil -> Path.expand(".devnoderc", elem(File.cwd, 1))
      path -> path
    end
  end

  def load(path) do
    parse(path, Mix.env)
  end

  def image_repo_path do
    [image_repo | _] = load(path)
    image_repo
    image_repo_props = elem(image_repo, 1)
    :proplists.get_value('path', image_repo_props) |> to_string
  end

  defp parse(path, :test) do
    #In test env we first eval an eex template
    hd(:yamerl_constr.string(EEx.eval_file(path, [])))
  end

  defp parse(path, _) do
    hd(:yamerl_constr.file(path))
  end
end

