defmodule Lime.Build do
  @moduledoc """
  Implements `build` CLI
  """
  @public "public"
  @content "content"

  defmacrop time(name, action) do
    quote do
      time_start = :os.timestamp
      unquote(action)
      time_end = :os.timestamp
      IO.puts "#{unquote(name)}: #{ :timer.now_diff(time_end, time_start) |> div(1000) } ms"
    end
  end

  @doc """
  Builds whole site.
  """
  def run() do
    pool = Lime.Pool.start
    {:ok, _} = Lime.Cache.start_link(:lime_posts, [{:write_concurrency, true}, :ordered_set])
    {:ok, _} = Lime.Cache.start_link(:lime_indexes, [])
    conf = File.read!("config.toml")
           |> Lime.Toml.parse
           |> update_in([:indexes], &Enum.map(&1, fn({index, name}) -> {index, String.to_atom(name)} end))
    publish_dir = conf[:publish_dir] || @public
    content_dir = conf[:content_dir] || @content
    clean publish_dir
    time "copy assets", Lime.Assets.copy(conf.theme, publish_dir)
    time "compile layouts", Lime.Layout.compile(conf.theme)
    time "compile posts", Lime.Page.render_all(pool, conf, content_dir, "post", publish_dir)
    time "compile pages", Lime.Page.render_all(pool, conf, content_dir, "", publish_dir)
    time "compile pagination", Lime.Paginator.run(pool, conf, publish_dir)
    time "compile indexes", Lime.Indexes.run(pool, conf, publish_dir)
  end

  defp clean publish_dir do
    File.rm_rf! publish_dir
    File.mkdir! publish_dir
  end
end
