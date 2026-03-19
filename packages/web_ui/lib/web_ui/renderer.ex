defmodule WebUi.Renderer do
  @moduledoc """
  Rendering pipeline for web_ui.

  This area provides the rendering logic that transforms:
  - Canonical UnifiedIUR representations into native widgets
  - Native widgets into Phoenix/Elm rendering structures
  - Bridge data for hydration and interop

  ## Submodules

  * `Canonical` - Maps UnifiedIUR elements to native web_ui widgets

  The renderer ensures that canonical IUR from the unified_ui DSL
  is correctly rendered in both server and client contexts.
  """

  alias WebUi.Renderer.Canonical

  @doc """
  Delegates to `Canonical.render/1`.
  """
  defdelegate render(element), to: Canonical

  @doc """
  Delegates to `Canonical.supported_kinds/0`.
  """
  defdelegate supported_kinds, to: Canonical

  @doc """
  Delegates to `Canonical.supports_kind?/1`.
  """
  defdelegate supports_kind?(kind), to: Canonical
end
