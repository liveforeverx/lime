defmodule Lime do
  @moduledoc """
  Implements logic to start an application and CLI for the escript.
  """
  use Application

  @doc """
  Callback for `Application.start`
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = []
    opts = [strategy: :one_for_one, name: Lime.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Main function for CLI.
  """
  @parse_opts [strict: [watch: :boolean, reload: :boolean, drafts: :boolean, dev: :boolean],
               aliases: [w: :watch, r: :reload, d: :drafts]]
  def main(arguments) do
    {options, values, _} = OptionParser.parse(arguments, @parse_opts)
    run(values, options)
  end

  def run(["init", path], options),  do: Lime.Init.run(path, options)
  def run(["new", _path], _options), do: throw :not_implemented_yet
  def run(["build"], options),       do: Lime.Build.run(options)
  def run(["server"], options),      do: Lime.Server.run(options)
  def run(_, _),                     do: help

  def help do
    IO.puts """
lime is the main command, used to build your Lime site.

Lime is a Static Site Generator built with love by liveforeverx and friends in Elixir.

Usage:
  lime [command]

Available Commands:
  server          Lime runs its own webserver to render the files
  version         Print the version number of Hugo
  init            Creates the scaffolding for the static site
  build           Compile the site to the public directory
"""
  end

end
