defmodule WebUi.Server.Error do
  @moduledoc """
  Structured errors for the Phoenix-side `web_ui` runtime scaffold.
  """

  @enforce_keys [:code, :message]
  defstruct [:code, :message, details: %{}]

  @type t :: %__MODULE__{
          code: atom(),
          message: String.t(),
          details: map()
        }

  @spec new(atom(), String.t(), map()) :: t()
  def new(code, message, details \\ %{}) when is_atom(code) and is_binary(message) do
    %__MODULE__{code: code, message: message, details: Map.new(details)}
  end

  @spec invalid_screen_module(module()) :: t()
  def invalid_screen_module(screen) do
    new(:invalid_screen_module, "screen module does not expose the required server callbacks", %{
      screen: inspect(screen)
    })
  end

  @spec invalid_mount_defaults(module()) :: t()
  def invalid_mount_defaults(screen) do
    new(:invalid_mount_defaults, "screen mount defaults must be a map", %{
      screen: inspect(screen)
    })
  end

  @spec invalid_view(module(), term()) :: t()
  def invalid_view(screen, view) do
    new(:invalid_view, "screen view must be a list of widget descriptor maps", %{
      screen: inspect(screen),
      value: inspect(view)
    })
  end

  @spec invalid_widget(module(), term()) :: t()
  def invalid_widget(screen, widget) do
    new(:invalid_widget, "widget descriptor must include at least :id and :kind", %{
      screen: inspect(screen),
      value: inspect(widget)
    })
  end

  @spec invalid_frontend_boot(module(), term()) :: t()
  def invalid_frontend_boot(screen, boot) do
    new(:invalid_frontend_boot, "screen frontend boot metadata must be a map or keyword list", %{
      screen: inspect(screen),
      value: inspect(boot)
    })
  end

  @spec invalid_event_route(module(), String.t()) :: t()
  def invalid_event_route(screen, event) do
    new(:invalid_event_route, "event does not have a registered server-side route", %{
      screen: inspect(screen),
      event: event
    })
  end

  @spec invalid_event_result(module(), atom(), term()) :: t()
  def invalid_event_result(screen, route, result) do
    new(:invalid_event_result, "screen event handler returned an invalid result", %{
      screen: inspect(screen),
      route: route,
      result: inspect(result)
    })
  end

  @spec invalid_sync_envelope(term()) :: t()
  def invalid_sync_envelope(envelope) do
    new(:invalid_sync_envelope, "sync envelope must contain kind, revision, and payload", %{
      value: inspect(envelope)
    })
  end
end
