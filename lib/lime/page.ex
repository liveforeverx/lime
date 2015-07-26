defmodule Lime.Page do
  alias Lime.Toml
  alias Lime.Pool

  def render_all(pool, conf, subdir) do
    {template, index, subdir_wildcard} = case subdir do
      "" -> {conf.layout.page, false, "*.md"}
      _  -> {conf.layout.post, true, Path.join(subdir, "*.md")}
    end
    files = Path.join(conf.content_dir, subdir_wildcard) |> Path.wildcard()
    Path.join(conf.publish_dir, subdir) |> File.mkdir_p!()
    Pool.set_state(pool, %{conf: conf, template: template, index: index})
    Enum.each(files, &Pool.run(pool, __MODULE__, :render, [&1]))
    Pool.sync_all(pool)
  end

  def render_defaults(_pool, conf) do
    rendered = CompiledLayout.render("404.html", conf, %{link: "#{conf.base_url}/404"})
    write_html(conf, "404", rendered)
   # rendered = CompiledLayout.render("404.html", meta.conf, %{})
   # write_html(meta.conf, relative_link, rendered)
  end

  def render(file, meta) do
    "+++\n" <> post = File.read!(file)
    [toml, markdown] = :binary.split(post, "\n+++\n")
    page = Toml.parse(toml)
    unless page[:draft] && (not meta.conf.drafts) do
      content = Earmark.to_html(markdown)
      relative_link = Path.rootname(file) |> Path.relative_to(meta.conf.content_dir)
      page = Map.merge(page, %{rel_link: relative_link,
                               link: "#{meta.conf.base_url}/#{relative_link}"})
      index_page(page, meta, markdown)
      rendered = CompiledLayout.render(meta.template, meta.conf, Map.put(page, :content, content))
      write_html(meta.conf, relative_link, rendered)
    end
  end

  def index_page(_page, %{index: false} = _meta, _markdown), do: nil
  def index_page(page, %{index: true} = meta, markdown) do
    case String.lstrip(markdown, ?\n) do
      "!" <> other ->
        [_, next] = :binary.split(other, "\n")
        index_page(page, meta, next)
      post_start ->
        [summary, _] = :binary.split(post_start, "\n")
        ConCache.dirty_put(:lime_posts, page.date, Map.put(page, :summary, summary))
        for {_, index} <- meta.conf.indexes, keys = page[index] || [],
            key <- keys do
          ConCache.update :lime_indexes, {index, key}, &({:ok, Map.put((&1 || %{}), page.title, page)})
        end
    end
  end

  def write_html(conf, relative_link, rendered) do
    html_file = Path.join(conf.publish_dir, relative_link) <> ".html"
    File.write!(html_file, rendered)
  end
end
