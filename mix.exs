defmodule Lime.Mixfile do
  use Mix.Project

  def project do
    [app: :lime,
     version: "0.1.0-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript,
     deps: deps]
  end

  def escript do
    [main_module: Lime]
  end


  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :etoml, :earmark, :calendar, :plug, :eex, :con_cache],
     mod: {Lime, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:etoml, github: "kalta/etoml"},
     {:earmark, "~> 0.1.0"},
     {:calendar, "~> 0.8.0"},
     {:cowboy, "~> 1.0.0"},
     {:plug, "~> 0.13.0"},
     {:con_cache, "~> 0.8.0"},
     {:sbroker, "~> 0.7.0"},
     {:exquisite, github: "meh/exquisite"},
     {:ex2ms, "~> 1.2.0"},
     {:rss, "~> 0.2.1"}]
  end
end
