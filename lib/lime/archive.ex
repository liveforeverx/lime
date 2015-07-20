defmodule Lime.Archive do
  @moduledoc """
  Used to load archive with build-in template in memory from priv.
  """

  @doc """
  Used during compilation to load the default theme from `priv` of application, for
  embedding in escript in code.
  """
  def load() do
    template_dir = :code.priv_dir(:lime) |> Path.join("template")
    files = [build_list(template_dir)] |> List.flatten
    {:ok, zip} = :zip.create('build_in_template', files, [:memory])
    {Path.relative_to_cwd(template_dir), zip}
  end

  defp build_list(file_or_dir) do
    if File.dir?(file_or_dir) do
      file_or_dir |> Path.join("*") |> Path.wildcard |> Enum.map(&build_list/1)
    else
      {Path.relative_to_cwd(file_or_dir) |> to_char_list, File.read!(file_or_dir)}
    end
  end
end
