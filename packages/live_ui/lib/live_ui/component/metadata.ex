defmodule LiveUi.Component.Metadata do
  @moduledoc """
  Declares the shared metadata contract for native `live_ui` widgets.
  """

  @enforce_keys [:module, :family, :name]
  defstruct [
    :module,
    :family,
    :name,
    :component_module,
    :wrapper_module,
    assigns: [],
    slots: [],
    style_hooks: [],
    events: [],
    mountable?: false,
    local_state_keys: [],
    identity_keys: [],
    runtime_boundary: nil
  ]

  @type t :: %__MODULE__{
          module: module(),
          family: atom(),
          name: atom(),
          component_module: module() | nil,
          wrapper_module: module() | nil,
          assigns: [atom()],
          slots: [atom()],
          style_hooks: [LiveUi.Component.style_hook()],
          events: [LiveUi.Component.event_surface()],
          mountable?: boolean(),
          local_state_keys: [atom()],
          identity_keys: [atom()],
          runtime_boundary: :live_component | nil
        }

  @spec new(module(), keyword()) :: t()
  def new(module, opts) do
    %__MODULE__{
      module: module,
      family: Keyword.fetch!(opts, :family),
      name: Keyword.fetch!(opts, :name),
      component_module: Keyword.get(opts, :component_module),
      wrapper_module: Keyword.get(opts, :wrapper_module, module),
      assigns: Keyword.get(opts, :assigns, []),
      slots: Keyword.get(opts, :slots, []),
      style_hooks: Keyword.get(opts, :style_hooks, []),
      events: Keyword.get(opts, :events, []),
      mountable?: Keyword.get(opts, :mountable?, false),
      local_state_keys: Keyword.get(opts, :local_state_keys, []),
      identity_keys: Keyword.get(opts, :identity_keys, []),
      runtime_boundary: Keyword.get(opts, :runtime_boundary)
    }
  end
end
