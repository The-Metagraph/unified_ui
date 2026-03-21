defmodule WebUi do
  @moduledoc """
  Package entrypoint for the `web_ui` runtime scaffold.
  """

  alias WebUi.{
    Examples,
    Frontend,
    Info,
    Layer,
    Layout,
    Reference,
    Renderer,
    Runtime,
    Server,
    Tooling,
    Transport,
    Widgets
  }

  @type package_area :: :widgets | :layout | :layer | :runtime | :renderer | :transport | :tooling

  @spec package_areas() :: [package_area()]
  def package_areas do
    [:widgets, :layout, :layer, :runtime, :renderer, :transport, :tooling]
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

  @spec layout() :: module()
  def layout, do: Layout

  @spec layer() :: module()
  def layer, do: Layer

  @spec server() :: module()
  def server, do: Server

  @spec frontend() :: module()
  def frontend, do: Frontend

  @spec runtime() :: module()
  def runtime, do: Runtime

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
