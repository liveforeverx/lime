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
  def main(["init", path]) do
    Lime.Init.run(path)
  end

  def main(["page", _path]) do
    throw :not_implemented_yet
  end

  def main(["build"]) do
    Lime.Build.run
  end

  def main(["server"]) do
    Application.start :cowboy
    Application.start :plug
    IO.puts "Starting Cowboy server. Browse to http://localhost:4000/"
    IO.puts "Press <CTRL+C> <CTRL+C> to quit."
    { :ok, pid } = Plug.Adapters.Cowboy.http Lime.Plug.Server, []
    Process.link( pid )
    :timer.sleep(:infinity)
  end

  def main(_) do
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
