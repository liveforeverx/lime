defmodule Lime.Toml do
  def parse(binary) do
    case :etoml.parse(binary) do
      {:ok, toml} ->
        t2m(toml)
      {:error, error} ->
        throw error
    end
  end

  defp t2m([{_, _} | _] = toml),
    do: Enum.map(toml, fn({key, value}) -> {String.to_atom(key), t2m(value)} end) |> Enum.into(%{})
  defp t2m(value),
    do: value
end
