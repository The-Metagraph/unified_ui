defmodule WebUi.WidgetRegistrationRequest do
  @moduledoc """
  Normalized custom widget registration request contract.
  """

  alias WebUi.RuntimeContext
  alias WebUi.TypedError
  alias WebUi.WidgetDescriptor

  @enforce_keys [:descriptor, :implementation_ref, :requested_by, :context]
  defstruct [:descriptor, :implementation_ref, :requested_by, :context]

  @type t :: %__MODULE__{
          descriptor: WidgetDescriptor.t(),
          implementation_ref: String.t(),
          requested_by: String.t(),
          context: RuntimeContext.t()
        }

  @spec validate(map() | t()) :: {:ok, t()} | {:error, TypedError.t()}
  def validate(%__MODULE__{} = request), do: validate(Map.from_struct(request))

  def validate(request) when is_map(request) do
    with {:ok, descriptor} <- validate_descriptor(request),
         {:ok, implementation_ref} <-
           validate_non_empty_string(request, :implementation_ref, "widget_registration_request.invalid_implementation_ref"),
         {:ok, requested_by} <-
           validate_non_empty_string(request, :requested_by, "widget_registration_request.invalid_requested_by"),
         {:ok, context} <- validate_context(request) do
      {:ok,
       %__MODULE__{
         descriptor: descriptor,
         implementation_ref: implementation_ref,
         requested_by: requested_by,
         context: context
       }}
    end
  end

  def validate(_request) do
    {:error,
     TypedError.new(
       "widget_registration_request.invalid_shape",
       "validation",
       false,
       %{reason: "registration request must be a map"}
     )}
  end

  defp validate_descriptor(request) do
    case fetch_any(request, :descriptor) do
      descriptor when is_map(descriptor) ->
        WidgetDescriptor.validate(descriptor)

      _ ->
        {:error,
         TypedError.new(
           "widget_registration_request.invalid_descriptor",
           "validation",
           false,
           %{field: :descriptor}
         )}
    end
  end

  defp validate_context(request) do
    case fetch_any(request, :context) do
      context when is_map(context) -> RuntimeContext.validate(context)
      _ -> {:error, TypedError.new("widget_registration_request.invalid_context", "validation", false, %{field: :context})}
    end
  end

  defp validate_non_empty_string(request, key, error_code) do
    case fetch_any(request, key) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:error, TypedError.new(error_code, "validation", false, %{field: key})}
    end
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
