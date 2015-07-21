defmodule Lime.Indexes do
  import Exquisite
  alias Lime.Pool

  def run(pool, conf) do
    Pool.set_state(pool, conf)
    for index <- conf.indexes, do: Pool.run(pool, __MODULE__, :render, [index])
    Pool.sync_all(pool)
  end

  def render({index, name}, conf) do
    relative_link = "#{name}"
    indexes = :ets.select(:lime_indexes, (match {{index_name, tag}, links}, where: index_name == name, select: {tag, links}))
    page = %{rel_link: relative_link,
             link: "#{conf.base_url}/#{relative_link}",
             title: String.capitalize(relative_link),
             index: name,
             indexes: indexes}
    rendered = CompiledLayout.render("indexes/#{relative_link}.html", conf, page)
    Lime.Page.write_html(conf, relative_link, rendered)
    Path.join(conf.publish_dir, relative_link) |> File.mkdir_p!()
    template = "indexes/#{index}.html"
    for {tag, posts} <- indexes do
      relative_link = "#{name}/#{tag}"
      page = %{rel_link: relative_link,
               link: "#{conf.base_url}/#{relative_link}",
               title: String.capitalize(tag),
               posts: posts}
      rendered = CompiledLayout.render(template, conf, page)
      Lime.Page.write_html(conf, relative_link, rendered)
    end
  end
end
