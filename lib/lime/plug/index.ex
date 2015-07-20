defmodule Lime.Plug.Index do
   @moduledoc """
   A plug to serve a built `*.html` from the build directory
   on requests to the server's.
   """

   @behaviour Plug

   @doc """
   Callback function for `Plug.init/1`.
   """
   def init(opts), do: opts

   @doc """
   Callback function for `Plug.call/2`.
   """
   def call(%Plug.Conn{path_info: path, state: state} = conn, _opts) when state in [:unset, :set] do
     path = case path do
       [] -> Path.expand("public/index.html")
       _ -> (Path.join(["public" | path]) |> Path.expand()) <> ".html"
     end
     if File.exists? path do
       conn
         |> Plug.Conn.send_file(200, path)
         |> Plug.Conn.halt
     else
       conn
     end
   end
   def call(conn, _opts), do: conn
 end
