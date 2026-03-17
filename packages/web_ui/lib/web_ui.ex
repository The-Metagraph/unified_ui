defmodule WebUi do
  @moduledoc """
  Package entrypoint for the `web_ui` runtime library.
  """

  alias WebUi.{
    Examples,
    Frontend,
    Info,
    Reference,
    Renderer,
    Runtime,
    Server,
    Tooling,
    Transport,
    Widgets
  }

  @type module_area ::
          :widgets
          | :server_runtime
          | :frontend_runtime
          | :runtime
          | :renderer
          | :transport
          | :reference
          | :info
          | :examples
          | :tooling

  @module_areas %{
    widgets: Widgets,
    server_runtime: Server,
    frontend_runtime: Frontend,
    runtime: Runtime,
    renderer: Renderer,
    transport: Transport,
    reference: Reference,
    info: Info,
    examples: Examples,
    tooling: Tooling
  }

  @spec package_identity() :: map()
  def package_identity do
    %{
      app: :web_ui,
      namespace: __MODULE__,
      package_path: "packages/web_ui",
      runtime_split: %{server: Server, frontend: Frontend},
      owns_dsl?: false,
      owns_iur_model?: false
    }
  end

  @spec module_areas() :: %{module_area() => module()}
  def module_areas do
    @module_areas
  end

  @spec module_for(module_area()) :: {:ok, module()} | :error
  def module_for(area) do
    Map.fetch(@module_areas, area)
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

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
