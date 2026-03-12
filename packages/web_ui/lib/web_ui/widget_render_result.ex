defmodule WebUi.WidgetRenderResult do
  @moduledoc """
  Normalized widget render result contract.
  """

  alias WebUi.Observability.RuntimeEvent
  alias WebUi.TypedError

  @enforce_keys [:widget_id, :outcome, :events]
  defstruct [:widget_id, :outcome, :node, :error, :events]

  @type t :: %__MODULE__{
          widget_id: String.t(),
          outcome: String.t(),
          node: map() | nil,
          error: TypedError.t() | nil,
          events: [map()]
        }

  @spec success(String.t(), map(), map(), [map()]) :: t()
  def success(widget_id, node, context, extra_events \\ [])
      when is_binary(widget_id) and is_map(node) and is_map(context) and is_list(extra_events) do
    %__MODULE__{
      widget_id: widget_id,
      outcome: "ok",
      node: node,
      error: nil,
      events: [rendered_event(widget_id, context) | extra_events]
    }
  end

  @spec error(String.t(), TypedError.t(), map(), [map()]) :: t()
  def error(widget_id, %TypedError{} = typed_error, context, extra_events \\ [])
      when is_binary(widget_id) and is_map(context) and is_list(extra_events) do
    %__MODULE__{
      widget_id: widget_id,
      outcome: "error",
      node: nil,
      error: typed_error,
      events: [render_failed_event(widget_id, typed_error, context) | extra_events]
    }
  end

  defp rendered_event(widget_id, context) do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: "runtime.widget.rendered.v1",
          event_version: "v1",
          timestamp: deterministic_timestamp(context, widget_id, "rendered"),
          service: "widget",
          source: "WebUi.Widget",
          outcome: "ok",
          payload: %{widget_id: widget_id}
        },
        context
      )

    Map.put(event, :widget_id, widget_id)
  end

  defp render_failed_event(widget_id, typed_error, context) do
    {:ok, event} =
      RuntimeEvent.build(
        %{
          event_name: "runtime.widget.render_failed.v1",
          event_version: "v1",
          timestamp: deterministic_timestamp(context, widget_id, "render_failed"),
          service: "widget",
          source: "WebUi.Widget",
          outcome: "error",
          correlation_id: Map.get(context, :correlation_id, typed_error.correlation_id),
          payload: %{
            widget_id: widget_id,
            error_code: typed_error.error_code,
            category: typed_error.category
          }
        },
        context
      )

    event
    |> Map.put(:widget_id, widget_id)
    |> Map.put(:error_code, typed_error.error_code)
    |> Map.put(:category, typed_error.category)
  end

  defp deterministic_timestamp(context, widget_id, marker)
       when is_map(context) and is_binary(widget_id) and is_binary(marker) do
    correlation_id =
      Map.get(context, :correlation_id) || Map.get(context, "correlation_id") || "unknown"

    request_id = Map.get(context, :request_id) || Map.get(context, "request_id") || "unknown"
    seed = :erlang.phash2({widget_id, correlation_id, request_id, marker}, 86_400)
    DateTime.from_unix!(1_700_000_000 + seed, :second) |> DateTime.to_iso8601()
  end
end
