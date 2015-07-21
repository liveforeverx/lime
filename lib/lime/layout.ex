defmodule Lime.Layout do
  def compile(conf) do
    layout_theme = "themes/#{conf.theme}/layouts"
    overwrite_layouts = Path.wildcard("layouts/**/*.html") |> Enum.map &(Path.relative_to(&1, "layouts"))
    theme_layouts = Path.join(layout_theme, "**/*.html")
                    |> Path.wildcard
                    |> Stream.map(&Path.relative_to(&1, layout_theme))
                    |> Stream.filter(&(not &1 in overwrite_layouts))
                    |> Enum.map(&({layout_theme, &1}))
    layouts = Enum.map(overwrite_layouts, fn(layout) -> {"layouts", layout} end) |> Enum.into(theme_layouts)
    layout_module(layouts)
  end

  defp layout_module(layouts) do
    quoted_layouts = Enum.map(layouts, &layout_to_quoted/1)
    quote do
      defmodule CompiledLayout do
        unquote(quoted_layouts)
        def strftime(datetime, format \\ "%b %d, %Y") when is_binary(datetime) do
          {:ok, parsed} = Calendar.DateTime.Parse.rfc3339_utc(datetime)
          {:ok, binary} = Calendar.Strftime.strftime(parsed, format)
          binary
        end
      end
    end |> Code.compile_quoted
  end

  defp layout_to_quoted({dir, layout}) do
    filename = Path.join(dir, layout)
    body = EEx.compile_file(filename) |> Macro.prewalk(&render_partials/1)
    quote do
      def render(unquote(layout), unquote(Macro.var(:conf, nil)), unquote(Macro.var(:page, nil))) do
        unquote(body)
      end
    end
  end

  defp render_partials({:partial, meta, [file]}) do
    {:render, meta, [ Path.join("partials", file), Macro.var(:conf, nil), Macro.var(:page, nil)]}
  end
  defp render_partials(ast) do
    ast
  end
end
