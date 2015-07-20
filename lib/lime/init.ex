defmodule Lime.Init do
  @moduledoc """
  Implementation for CLI `init` command. It scaffolds your blog.
  """
  @dirs ["content", "static", "layout"]

  @doc """
  Initial scaffolding of your blog.
  """
  def run(path) do
    {rel_path, {_, zip}} = archive
    :zip.unzip(zip, [:memory]) |> elem(1) |> write_files(rel_path, path)
    @dirs |> Enum.map(&(Path.join(path, &1) |> File.mkdir_p!))
    Path.join(path, "config.toml") |> File.write!(config())
  end

  defp archive() do
    unquote(Lime.Archive.load)
  end

  defp write_files(files, rel_path, path) do
    for {filename, binary} <- files do
      rel_filename = Path.relative_to(filename, rel_path)
      filename = Path.join(path, rel_filename)
      filename |> Path.dirname() |> File.mkdir_p!
      File.write!(filename, binary)
    end
  end

  defp config() do
    """
content_dir = "content"
publish_dir = "public"
base_url = "http://localhost:4000"
title = "Start blogging"
theme = "pixyll"
author = "Generated"
copyright = ""
paginate = 10

[indexes]
  tag = "tags"

[params]
  google_analytics_id = ""
  disqus_shortname = "sitename"

[layout]
  index = "index.html"
  page = "page/single.html"
  post = "post/single.html"
"""
  end
end
