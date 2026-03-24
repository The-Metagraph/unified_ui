defmodule DesktopUi.Platform.Linux do
  @moduledoc """
  Linux adapter seam for `desktop_ui`.
  """

  @behaviour DesktopUi.Platform.Adapter

  @impl true
  def summary do
    %{
      target: :linux,
      capabilities: capabilities(),
      callbacks: callbacks(),
      notifications: :desktop_portal,
      menus: :window_local_menu
    }
  end

  @impl true
  def capabilities do
    [:windowing, :menus, :shortcuts, :notifications]
  end

  @impl true
  def callbacks do
    [:lifecycle, :focus, :window_management]
  end
end
