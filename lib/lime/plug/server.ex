defmodule Lime.Plug.Server do
  @moduledoc """
  A plug to serve a static files during development, with extension for beauty urls.
  """
  use Plug.Builder

  plug Plug.Static, at: "/", from: "public"
  plug Lime.Plug.Index
  plug :not_found

  @doc """
  Sends all unknown requests a 404.
  """
  def not_found(conn, _) do
    Plug.Conn.send_file(conn, 404, "public/404.html") |> Plug.Conn.halt
  end
end
