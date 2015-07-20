defmodule Lime.Cache do
  @moduledoc """
  Simplifiers for working with `con_cache`
  """

  @doc """
  Used for starting `ConCache`, with name and ets options. For more information, refer `ConCache.start_link/2`
  """
  def start_link(name, ets_opts) do
    ConCache.start_link([ets_options: [:named_table, {:name, name} | ets_opts]],
                        [name: name])
  end
end
