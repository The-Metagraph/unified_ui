defmodule Demo.Application do
  @moduledoc """
  Demo application entry point.

  This is a standalone demo application for desktop_ui that demonstrates
  all available widgets with navigation between screens.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Navigation controller for the demo
      {DesktopUi.Navigation.Controller,
       name: :demo_nav, registry: Demo.Screens, initial_screen: {:home, Demo.Screens.Home, %{}}}
    ]

    opts = [strategy: :one_for_one, name: Demo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def stop(_state) do
    :ok
  end

  @doc """
  Run the demo application.
  """
  def run do
    # Get the navigation controller state
    nav_state = DesktopUi.Navigation.Controller.get_state(:demo_nav)

    # Build the main demo screen
    screen = Demo.Screens.Main.render(%{
      nav_controller: :demo_nav,
      current_screen: nav_state.current,
      screen_params: nav_state.current_params
    })

    # Mount the screen using desktop_ui runtime
    {:ok, runtime_state} = DesktopUi.Runtime.mount_native_screen(screen)

    IO.puts("Desktop UI Demo started!")
    IO.puts("Navigation controller: #{inspect(:demo_nav)}")
    IO.puts("Current screen: #{nav_state.current}")

    runtime_state
  end
end
