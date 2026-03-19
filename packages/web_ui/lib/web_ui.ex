defmodule WebUi do
  @moduledoc """
  Package entrypoint for the `web_ui` runtime library.

  `web_ui` provides a Phoenix + Elm split runtime for the unified ecosystem.
  It combines a Phoenix server backend for server-authoritative rendering with
  an Elm frontend for client-side interactivity.

  ## Package Areas

  * `:widgets` - Native widget modules for direct use
  * `:server_runtime` - Phoenix server-side runtime entrypoints
  * `:frontend_runtime` - Elm client-side runtime modules
  * `:renderer` - Canonical IUR rendering through the Phoenix + Elm pipeline
  * `:transport` - Signal transport and browser bridge
  * `:tooling` - Development and maintenance helpers

  ## Architecture

  The web_ui package follows a split runtime architecture:

  1. **Server (Phoenix)** - Handles initial rendering, server-authoritative state,
     and provides canonical IUR rendering endpoints

  2. **Client (Elm)** - Handles client-side interactivity, local state updates,
     and communicates with the server via the transport layer

  This split allows web_ui to leverage Phoenix's real-time capabilities while
  providing Elm's type-safe client-side experience.
  """

  alias WebUi.{
    ServerRuntime,
    FrontendRuntime,
    Renderer,
    Widgets,
    Transport,
    Tooling,
    Info,
    Reference
  }

  @type package_area :: :widgets | :server_runtime | :frontend_runtime | :renderer | :transport | :tooling

  @spec package_areas() :: [package_area()]
  def package_areas do
    [:widgets, :server_runtime, :frontend_runtime, :renderer, :transport, :tooling]
  end

  @spec widgets() :: module()
  def widgets, do: Widgets

  @spec server_runtime() :: module()
  def server_runtime, do: ServerRuntime

  @spec frontend_runtime() :: module()
  def frontend_runtime, do: FrontendRuntime

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
