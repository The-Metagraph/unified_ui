defmodule LiveUi.Screen do
  @moduledoc """
  Shared contract for direct-use native `live_ui` screens.
  """

  alias LiveUi.Screen.Definition

  @callback id() :: atom()
  @callback title() :: String.t()
  @callback mount_defaults() :: map()
  @callback render(map()) :: Phoenix.LiveView.Rendered.t()
  @callback metadata() :: map()

  @spec definition(module()) :: Definition.t()
  def definition(module) do
    %Definition{
      module: module,
      id: module.id(),
      title: module.title(),
      mount_defaults: module.mount_defaults(),
      metadata: module.metadata()
    }
  end

  defmacro __using__(opts) do
    screen_id = Keyword.fetch!(opts, :id)
    title = Keyword.get(opts, :title, Macro.camelize(to_string(screen_id)))

    quote bind_quoted: [screen_id: screen_id, title: title] do
      use Phoenix.Component

      @behaviour LiveUi.Screen
      @live_ui_screen_id screen_id
      @live_ui_screen_title title

      @impl true
      def id, do: @live_ui_screen_id

      @impl true
      def title, do: @live_ui_screen_title

      @impl true
      def mount_defaults, do: %{}

      @impl true
      def metadata do
        %{
          kind: :native_screen,
          server_authoritative?: true,
          browser_bridge?: false
        }
      end

      defoverridable title: 0, mount_defaults: 0, metadata: 0
    end
  end
end
