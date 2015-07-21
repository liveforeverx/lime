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
      nil
    end
  end

  @doc """
  Builds whole site.
  """
  def run(options) do
    pool = init()
    conf = read_conf()
    clean conf.publish_dir

    copy_assets(conf)
    compile_layouts(pool, conf)
    if options[:watch] do
      load_fs()
      watch(pool, conf)
    end
  end

  defp rerun(pool) do
    conf = read_conf()
    copy_assets(conf)
    compile_layouts(pool, conf)
    conf
  end

  defp copy_assets(conf) do
    time "copy assets", Lime.Assets.copy(conf)
    conf
  end

  defp compile_layouts(pool, conf) do
    time "compile layouts", Lime.Layout.compile(conf)
    clean()
    compile_content(pool, conf)
  end

  defp compile_content(pool, conf) do
    compile_pages(pool, conf)
    compile_posts(pool, conf)
  end

  defp compile_pages(pool, conf) do
    time "compile posts", Lime.Page.render_all(pool, conf, "post")
  end

  defp compile_posts(pool, conf) do
    time "compile pages", Lime.Page.render_all(pool, conf, "")
    time "compile pagination", Lime.Paginator.run(pool, conf)
    time "compile indexes", Lime.Indexes.run(pool, conf)
  end

  defp init() do
    {:ok, _} = Lime.Cache.start_link(:lime_posts, [{:write_concurrency, true}, :ordered_set])
    {:ok, _} = Lime.Cache.start_link(:lime_indexes, [])
    Lime.Pool.start
  end

  defp read_conf() do
    File.read!("config.toml")
    |> Lime.Toml.parse
    |> update_in([:indexes], &Enum.map(&1, fn({index, name}) -> {index, String.to_atom(name)} end))
    |> Map.put_new(:publish_dir, @public)
    |> Map.put_new(:content_dir, @content)
  end

  defp clean() do
    for tab <- [:lime_posts, :lime_indexes], do: :ets.delete_all_objects(tab)
  end

  # brutal hack
  defp load_fs do
    {:ok, _} = Application.ensure_all_started(:fs)
    :fs.subscribe
  end

  def watch(pool, conf = %{content_dir: content_dir, publish_dir: publish_dir}) do
    receive do
      {_, {:fs, :file_event}, {file, _}} ->
        new_conf? = case file = Path.relative_to_cwd(file) do
          "config.toml" <> _ -> rerun(pool)
          "static" <> _      -> copy_assets(conf)
          "layouts" <> _     -> compile_layouts(pool, conf)
          _ ->
            if match?({0, _}, :binary.match(file, content_dir)) do
              compile_content(pool, conf)
            else if match?({0, _}, :binary.match(file, publish_dir)) do
              watch(pool, conf)
            else
              IO.puts "ignore file event #{file}"
              nil
            end end
        end
        watch(pool, new_conf? || conf)
    end
  end

  defp clean publish_dir do
    File.rm_rf! publish_dir
    File.mkdir! publish_dir
  end
end
