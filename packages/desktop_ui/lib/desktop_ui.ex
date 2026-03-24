defmodule DesktopUi do
  @moduledoc """
  Package entrypoint for the `desktop_ui` runtime scaffold.
  """

  alias DesktopUi.{
    Artifacts,
    Info,
    Inspection,
    Platform,
    Reference,
    Renderer,
    Runtime,
    Tooling,
    Transport,
    Widget,
    Widgets
  }

  @type package_area ::
          :widgets
          | :runtime
          | :platform
          | :renderer
          | :transport
          | :artifacts
          | :inspection
          | :tooling

  @spec package_areas() :: [package_area()]
  def package_areas do
    [:widgets, :runtime, :platform, :renderer, :transport, :artifacts, :inspection, :tooling]
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

  @spec widget() :: module()
  def widget, do: Widget

  @spec runtime() :: module()
  def runtime, do: Runtime

  @spec platform() :: module()
  def platform, do: Platform

  @spec renderer() :: module()
  def renderer, do: Renderer

  @spec transport() :: module()
  def transport, do: Transport

  @spec artifacts() :: module()
  def artifacts, do: Artifacts

  @spec inspection() :: module()
  def inspection, do: Inspection

  @spec tooling() :: module()
  def tooling, do: Tooling

  @spec reference() :: map()
  def reference, do: Reference.package_reference()

  @spec info() :: map()
  def info, do: Info.package_summary()
end
