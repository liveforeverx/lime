defmodule Lime.Paginator do
  import Exquisite

  def run(_pool, conf, publish_dir) do
    paginate = conf[:paginate] || 1
    template = conf.layout.index
    meta = %{conf: conf, template: template, publish: publish_dir}
    all_pages = div(:ets.info(:lime_posts, :size) - 1, paginate)
    Path.join(publish_dir, "page") |> File.mkdir_p!()
    recursive_run(meta, 0, all_pages, paginate)
  end

  defp recursive_run(meta, 0, last_page, paginate) do
    {posts, cont} = :ets.select_reverse(:lime_posts, (match {date, data}, select: data), paginate)
    render(meta, posts, 0, last_page)
    recursive_run(meta, cont, 1, last_page, paginate)
  end

  defp recursive_run(meta, cont, actual_page, last_page, paginate) when actual_page <= last_page do
    {posts, cont} = :ets.select_reverse(cont)
    render(meta, posts, actual_page, last_page)
    recursive_run(meta, cont, actual_page + 1, last_page, paginate)
  end

  defp recursive_run(_, _, _, _, _), do: nil

  def render(meta, posts, actual, last_page) do
    relative_link = rel_link(actual, last_page)
    page = %{paginator: %{page_number: actual,
                          prev_url: rel_link(actual - 1, last_page),
                          next_url: rel_link(actual + 1, last_page)},
             rel_link: relative_link,
             link: "#{meta.conf.base_url}/#{relative_link}",
             posts: posts}
    rendered = CompiledLayout.render(meta.template, meta.conf, page)
    Lime.Page.write_html(meta, may_be_index(relative_link), rendered)
  end

  defp rel_link(0, _), do: "/"
  defp rel_link(page, last_page) when page > 0 and page <= last_page, do: "/page/#{page}"
  defp rel_link(_, _), do: nil

  defp may_be_index("/"), do: "index"
  defp may_be_index(path), do: path
end
