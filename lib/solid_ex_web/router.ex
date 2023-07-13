defmodule SolidExWeb.Router do
  use SolidExWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", SolidExWeb do
    pipe_through :api
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:solid_ex, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SolidExWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Mix.env() == :dev do
    pipeline :insecure_browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :put_secure_browser_headers
    end

    scope "/" do
      pipe_through :insecure_browser

      forward "/", ReverseProxyPlug,
        upstream: "http://localhost:5173",
        error_callback: &__MODULE__.log_reverse_proxy_error/1

      def log_reverse_proxy_error(error) do
        require Logger
        Logger.error("ReverseProxyPlug network error: #{inspect(error)}")
      end
    end
  else
    scope "/", SolidExWeb do
      pipe_through :browser
      get "/*app", PageController, :app
    end
  end
end
