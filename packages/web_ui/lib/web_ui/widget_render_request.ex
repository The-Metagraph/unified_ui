defmodule WebUi.WidgetRenderRequest do
  @moduledoc """
  Normalized widget render request contract.
  """

  alias WebUi.RuntimeContext
  alias WebUi.TypedError

  @enforce_keys [:widget_id, :props, :state, :context]
  defstruct [:widget_id, :props, :state, :context]

  @type t :: %__MODULE__{
          widget_id: String.t(),
          props: map(),
          state: map(),
          context: RuntimeContext.t()
        }

  @spec validate(map() | t()) :: {:ok, t()} | {:error, TypedError.t()}
  def validate(%__MODULE__{} = request), do: validate(Map.from_struct(request))

  def validate(request) when is_map(request) do
    with {:ok, widget_id} <- validate_widget_id(request),
         {:ok, props} <- validate_map_field(request, :props, "widget_render_request.invalid_props"),
         {:ok, state} <- validate_state(request),
         {:ok, context} <- validate_context(request) do
      {:ok,
       %__MODULE__{
         widget_id: widget_id,
         props: props,
         state: state,
         context: context
       }}
    end
  end

  def validate(_request) do
    {:error,
     TypedError.new(
       "widget_render_request.invalid_shape",
       "validation",
       false,
       %{reason: "render request must be a map"}
     )}
  end

  defp validate_widget_id(request) do
    case fetch_any(request, :widget_id) do
      widget_id when is_binary(widget_id) ->
        if String.trim(widget_id) != "" do
          {:ok, widget_id}
        else
          {:error, TypedError.new("widget_render_request.invalid_widget_id", "validation", false, %{field: :widget_id})}
        end

      _ -> {:error, TypedError.new("widget_render_request.invalid_widget_id", "validation", false, %{field: :widget_id})}
    end
  end

  defp validate_state(request) do
    case fetch_any(request, :state) do
      nil -> {:ok, %{}}
      state when is_map(state) -> {:ok, state}
      _ -> {:error, TypedError.new("widget_render_request.invalid_state", "validation", false, %{field: :state})}
    end
  end

  defp validate_context(request) do
    case fetch_any(request, :context) do
      context when is_map(context) -> RuntimeContext.validate(context)
      _ -> {:error, TypedError.new("widget_render_request.invalid_context", "validation", false, %{field: :context})}
    end
  end

  defp validate_map_field(request, field, error_code) do
    case fetch_any(request, field) do
      value when is_map(value) -> {:ok, value}
      _ -> {:error, TypedError.new(error_code, "validation", false, %{field: field})}
    end
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
