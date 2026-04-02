defmodule LiveUi.Component do
  @moduledoc """
  Shared contract for native `live_ui` widgets.
  """

  alias LiveUi.Component.Metadata
  alias LiveUi.Widget.Identity

  @type assigns_contract :: [atom()]
  @type style_hook :: :tone | :variant | :state
  @type event_surface :: :click | :navigate | :submit | :change | :selection | :command

  @callback metadata() :: Metadata.t()
  @callback render(map()) :: Phoenix.LiveView.Rendered.t()

  @spec common_assigns() :: assigns_contract()
  def common_assigns do
    [:id, :metadata, :class, :tone, :variant, :state, :rest]
  end

  @spec style_hooks() :: [style_hook()]
  def style_hooks do
    [:tone, :variant, :state]
  end

  @spec metadata(module()) :: Metadata.t()
  def metadata(module) do
    module.metadata()
  end

  @spec component_module(module()) :: module()
  def component_module(module) when is_atom(module) do
    metadata(module).component_module || Module.concat(module, Component)
  end

  @spec widget_identity(module(), map() | keyword(), keyword()) :: Identity.t()
  def widget_identity(module, assigns, opts \\ []) when is_atom(module) do
    module
    |> metadata()
    |> Identity.new(assigns, opts)
  end

  defmacro common_attrs do
    quote do
      attr(:id, :string, required: true)
      attr(:metadata, :map, default: %{})
      attr(:class, :string, default: nil)
      attr(:tone, :string, default: nil)
      attr(:variant, :string, default: nil)
      attr(:state, :string, default: nil)
      attr(:rest, :global)
    end
  end

  defmacro __using__(opts) do
    family = Keyword.fetch!(opts, :family)
    name = Keyword.fetch!(opts, :name)
    slots = Keyword.get(opts, :slots, [])
    widget_assigns_contract = Keyword.get(opts, :assigns, [])
    widget_events = Keyword.get(opts, :events, [])
    widget_local_state_keys = Keyword.get(opts, :local_state_keys, [])

    quote bind_quoted: [
            family: family,
            name: name,
            slots: slots,
            widget_assigns_contract: widget_assigns_contract,
            widget_events: widget_events,
            widget_local_state_keys: widget_local_state_keys
          ] do
      use Phoenix.Component

      @behaviour LiveUi.Component

      @live_ui_component_family family
      @live_ui_component_name name
      @live_ui_component_slots slots
      @live_ui_component_assigns widget_assigns_contract
      @live_ui_component_events widget_events
      @live_ui_component_local_state_keys widget_local_state_keys

      wrapper_module = __MODULE__
      @live_ui_component_module Module.concat(__MODULE__, Component)

      defmodule Component do
        use LiveUi.Widget,
          wrapper: wrapper_module,
          family: family,
          name: name,
          slots: slots,
          assigns: widget_assigns_contract,
          events: widget_events,
          local_state_keys: widget_local_state_keys
      end

      @impl true
      def metadata do
        Metadata.new(__MODULE__,
          family: @live_ui_component_family,
          name: @live_ui_component_name,
          assigns: LiveUi.Component.common_assigns() ++ @live_ui_component_assigns,
          slots: @live_ui_component_slots,
          style_hooks: LiveUi.Component.style_hooks(),
          events: @live_ui_component_events,
          component_module: @live_ui_component_module,
          wrapper_module: __MODULE__,
          mountable?: true,
          local_state_keys: @live_ui_component_local_state_keys,
          identity_keys: [:id],
          runtime_boundary: :live_component
        )
      end

      def component(var!(assigns)) when is_map(var!(assigns)) do
        var!(assigns) =
          var!(assigns)
          |> Map.new()
          |> Map.put(:widget_assigns, Map.new(var!(assigns)))
          |> Map.put(:widget_component_module, @live_ui_component_module)
          |> Map.put(
            :widget_identity,
            LiveUi.Component.widget_identity(__MODULE__, var!(assigns))
          )

        ~H"""
        <.live_component
          module={@widget_component_module}
          id={@widget_identity.id}
          widget_assigns={@widget_assigns}
          widget_identity={@widget_identity}
        />
        """
      end

      defoverridable metadata: 0
    end
  end
end
