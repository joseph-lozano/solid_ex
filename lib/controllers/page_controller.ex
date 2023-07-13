defmodule SolidExWeb.PageController do
  use SolidExWeb, :controller

  # In prod, we can determine the html at compile time
  # Otherwise, we need to read it from the file system
  if Mix.env() == :dev do
    def app(_conn, _params) do
      raise """
      ERROR: When running in dev,
      requests are proxied to the vite servera.
      """
    end
  else
    @html :solid_ex |> :code.priv_dir() |> Path.join("static/index.html") |> File.read!()
    def app(conn, _params) do
      html(conn, @html)
    end
  end

  def api_test(conn, _params) do
    json(conn, %{message: "Hello from the backend!"})
  end

  def csrf(conn, _params) do
    json(conn, get_csrf_token())
  end
end
