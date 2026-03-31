defmodule LiveUi.Demo.Server.Router do
  @moduledoc false

  use Phoenix.Router

  import Phoenix.LiveView.Router

  alias LiveUi.Demo.Server.{Layouts, Live}

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)

    live("/", Live, :home, as: :demo)
    live("/examples/:example_id", Live, :example, as: :demo)
  end
end
