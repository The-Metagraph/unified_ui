defmodule LiveUi.Component do
  @moduledoc """
  Shared contract for native `live_ui` widgets.
  """

  alias LiveUi.Component.Metadata

  @type assigns_contract :: [atom()]

  @callback metadata() :: Metadata.t()
  @callback render(map()) :: Phoenix.LiveView.Rendered.t()

  @spec common_assigns() :: assigns_contract()
  def common_assigns do
    [:id, :metadata, :class, :rest]
  end

  @spec metadata(module()) :: Metadata.t()
  def metadata(module) do
    module.metadata()
  end

  defmacro common_attrs do
    quote do
      attr(:id, :string, required: true)
      attr(:metadata, :map, default: %{})
      attr(:class, :string, default: nil)
      attr(:rest, :global)
    end
  end

  defmacro __using__(opts) do
    family = Keyword.fetch!(opts, :family)
    name = Keyword.fetch!(opts, :name)
    slots = Keyword.get(opts, :slots, [])
    assigns = Keyword.get(opts, :assigns, [])

    quote bind_quoted: [family: family, name: name, slots: slots, assigns: assigns] do
      use Phoenix.Component

      @behaviour LiveUi.Component

      @live_ui_component_family family
      @live_ui_component_name name
      @live_ui_component_slots slots
      @live_ui_component_assigns assigns

      @impl true
      def metadata do
        Metadata.new(__MODULE__,
          family: @live_ui_component_family,
          name: @live_ui_component_name,
          assigns: LiveUi.Component.common_assigns() ++ @live_ui_component_assigns,
          slots: @live_ui_component_slots
        )
      end

      defoverridable metadata: 0
    end
  end
end
