defmodule Lime.Server do
  def run(options) do
    Application.start :cowboy
    Application.start :plug
    IO.puts "Starting Cowboy server. Browse to http://localhost:4000/"
    IO.puts "Press <CTRL+C> <CTRL+C> to quit."
    { :ok, pid } = Plug.Adapters.Cowboy.http Lime.Plug.Server, []
    Process.link( pid )
    if options[:watch], do: Lime.Build.run(options)
  end
end
