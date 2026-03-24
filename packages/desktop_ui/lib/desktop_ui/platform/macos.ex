defmodule DesktopUi.Platform.MacOS do
  @moduledoc """
  macOS adapter seam for `desktop_ui`.
  """

  @behaviour DesktopUi.Platform.Adapter

  @impl true
  def summary do
    %{
      target: :macos,
      capabilities: capabilities(),
      callbacks: callbacks(),
      notifications: :user_notifications,
      menus: :application_menu
    }
  end

  @impl true
  def capabilities do
    [:windowing, :menus, :shortcuts, :notifications, :file_open]
  end

  @impl true
  def callbacks do
    [:lifecycle, :focus, :file_open, :window_management]
  end
end
