defmodule Lime.Assets do
  @moduledoc """
  Module, which handles static assets
  """

  @doc """
  All static files from theme and project will be copied to a configured `publish_dir`
  """
  def copy(conf) do
    File.cp_r("themes/#{conf.theme}/static", conf.publish_dir)
    File.cp_r("static", conf.publish_dir)
  end
end
