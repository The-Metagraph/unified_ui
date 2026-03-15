defmodule LiveUi do
  @moduledoc """
  Package entrypoint for the `live_ui` runtime library.
  """

  alias LiveUi.{
    Display,
    Examples,
    Forms,
    Info,
    Layout,
    Layer,
    Reference,
    Renderer,
    Runtime,
    Screen,
    Tooling,
    Transport,
    Viewport,
    Widgets
  }

  @type package_area :: :widgets | :runtime | :renderer | :transport | :tooling

  @spec package_areas() :: [package_area()]
  def package_areas do
    [:widgets, :runtime, :renderer, :transport, :tooling]
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

  @spec forms() :: module()
  def forms, do: Forms

  @spec examples() :: module()
  def examples, do: Examples

  @spec layout() :: module()
  def layout, do: Layout

  @spec display() :: module()
  def display, do: Display

  @spec layer() :: module()
  def layer, do: Layer

  @spec viewport() :: module()
  def viewport, do: Viewport

  @spec screen() :: module()
  def screen, do: Screen

  @spec runtime() :: module()
  def runtime, do: Runtime

  @spec renderer() :: module()
  def renderer, do: Renderer

  @spec transport() :: module()
  def transport, do: Transport

  @spec tooling() :: module()
  def tooling, do: Tooling

  @spec reference() :: map()
  def reference, do: Reference.package_reference()

  @spec info() :: map()
  def info, do: Info.package_summary()
end
