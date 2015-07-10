defmodule Devnode.Support.TestDir do
  def remove do
    File.rm_rf!(tmp_dir)
  end

  def mk_sub_dir(sub_path) do
    path =  tmp_dir <> sub_path
    File.mkdir_p(path)
    path
  end

  defp tmp_dir do
    System.tmp_dir() <> "/devnode_test/"
  end
end
