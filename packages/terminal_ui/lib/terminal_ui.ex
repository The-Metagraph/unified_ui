defmodule TerminalUi do
  @moduledoc """
  Package entrypoint for the `terminal_ui` runtime scaffold.
  """

  alias TerminalUi.{
    Backend,
    Capabilities,
    Examples,
    Info,
    Style,
    Theme,
    Layout,
    Layer,
    Reference,
    Renderer,
    Runtime,
    Tooling,
    Transport,
    Widgets
  }

  @type package_area ::
          :widgets
          | :runtime
          | :backend
          | :capabilities
          | :style
          | :theme
          | :layout
          | :layer
          | :renderer
          | :transport
          | :tooling

  @spec package_areas() :: [package_area()]
  def package_areas do
    [
      :widgets,
      :runtime,
      :backend,
      :capabilities,
      :style,
      :theme,
      :layout,
      :layer,
      :renderer,
      :transport,
      :tooling
    ]
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

  @spec runtime() :: module()
  def runtime, do: Runtime

  @spec backend() :: module()
  def backend, do: Backend

  @spec capabilities() :: module()
  def capabilities, do: Capabilities

  @spec style() :: module()
  def style, do: Style

  @spec theme() :: module()
  def theme, do: Theme

  @spec layout() :: module()
  def layout, do: Layout

  @spec layer() :: module()
  def layer, do: Layer

  @spec renderer() :: module()
  def renderer, do: Renderer

  @spec transport() :: module()
  def transport, do: Transport

  @spec tooling() :: module()
  def tooling, do: Tooling

  @spec examples() :: module()
  def examples, do: Examples

  @spec reference() :: map()
  def reference, do: Reference.package_reference()

  @spec info() :: map()
  def info, do: Info.package_summary()
end
