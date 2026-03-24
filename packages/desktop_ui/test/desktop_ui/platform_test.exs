defmodule DesktopUi.PlatformTest do
  use ExUnit.Case, async: true

  alias DesktopUi.Platform

  test "platform adapters stay bounded behind the shared registry" do
    assert Platform.targets() == [:windows, :macos, :linux]

    assert {:ok, %{target: :linux, adapter: DesktopUi.Platform.Linux}} =
             Platform.select(platform_target: :linux)

    assert Platform.adapter_summary(:windows).menus == :native_menu_bar
    assert Platform.adapter_summary(:macos).notifications == :user_notifications
  end

  test "invalid adapter registration and callback payloads fail deterministically" do
    assert {:error, {:invalid_platform_adapter, :linux}} =
             Platform.select(platform_target: :linux, adapter_registry: %{linux: DesktopUi})

    assert {:error, %{reason: :unsupported_platform_callback, callback: :printer_ready}} =
             Platform.validate_callback_payload(:printer_ready, %{})

    assert {:error, %{reason: :invalid_callback_payload, callback: :lifecycle}} =
             Platform.validate_callback_payload(:lifecycle, :not_a_map)
  end
end
