defmodule Lime.Assets do
  @moduledoc """
  Module, which handles static assets
  """

  @doc """
  All static files from theme and project will be copied to a configured `publish_dir`
  """
  def copy(theme, publish_dir) do
    File.cp_r("themes/#{theme}/static", publish_dir)
    File.cp_r("static", publish_dir)
  end
end
