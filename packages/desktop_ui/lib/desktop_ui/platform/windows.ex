defmodule DesktopUi.Platform.Windows do
  @moduledoc """
  Windows adapter seam for `desktop_ui`.
  """

  @behaviour DesktopUi.Platform.Adapter

  @impl true
  def summary do
    %{
      target: :windows,
      capabilities: capabilities(),
      callbacks: callbacks(),
      notifications: :system_toast,
      menus: :native_menu_bar
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
