defmodule WebUi.Server.Screen do
  @moduledoc """
  Behaviour and helper macro for direct-native `web_ui` server screens.
  """

  @callback id() :: atom()
  @callback title() :: String.t()
  @callback mount_defaults() :: map()
  @callback event_routes() :: %{optional(String.t()) => atom()}
  @callback view(map()) :: [map()]
  @callback handle_event(atom(), map(), map()) :: {:ok, map()} | {:error, term()}
  @callback frontend_boot() :: map()

  defmacro __using__(opts) do
    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)

    quote do
      @behaviour WebUi.Server.Screen

      @impl true
      def id, do: unquote(id)

      @impl true
      def title, do: unquote(title)

      @impl true
      def frontend_boot, do: %{}

      defoverridable frontend_boot: 0
    end
  end

  @spec definition(module()) :: map()
  def definition(screen) when is_atom(screen) do
    %{
      module: screen,
      id: screen.id(),
      title: screen.title(),
      mount_defaults: screen.mount_defaults(),
      event_routes: screen.event_routes(),
      frontend_boot: screen.frontend_boot()
    }
  end
end
