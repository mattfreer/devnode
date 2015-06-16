defmodule Devnode.Client.ImageRepo do

  def dir do
    System.tmp_dir() <> "/devnode/image_repo/"
  end
end
