defmodule Lime.Indexes do
  import Exquisite
  alias Lime.Pool

  def run(pool, conf) do
    Pool.set_state(pool, conf)
    for index <- conf.indexes, do: Pool.run(pool, __MODULE__, :render, [index])
    Pool.sync_all(pool)
  end

  def render({index, name}, conf) do
    indexes = :ets.select(:lime_indexes, (match {{index_name, tag}, links}, where: index_name == name, select: {tag, links}))
    indexes = for {tag, values} <- indexes do
      relative_link = index_link(name, tag)
      {tag, %{rel_link: relative_link,
              link: "#{conf.base_url}/#{relative_link}",
              title: String.capitalize(tag),
              index: name,
              index_key: tag,
              posts: values}}
    end
    relative_link = "#{name}"
    page = %{rel_link: relative_link,
             link: "#{conf.base_url}/#{relative_link}",
             title: String.capitalize(relative_link),
             index: name,
             indexes: indexes}
    rendered = CompiledLayout.render("indexes/#{relative_link}.html", conf, page)
    Lime.Page.write_html(conf, relative_link, rendered)
    Path.join(conf.publish_dir, relative_link) |> File.mkdir_p!()
    template = "indexes/#{index}.html"
    for {_, page} <- indexes do
      rendered = CompiledLayout.render(template, conf, page)
      Lime.Page.write_html(conf, page.rel_link, rendered)
    end
  end

  def index_link(index, name) do
    "#{index}/#{name |> String.replace(" ", "-")}"
  end
end
