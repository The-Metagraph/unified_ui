defmodule WebUi.WidgetDescriptor do
  @moduledoc """
  Canonical widget descriptor metadata contract.
  """

  alias WebUi.TypedError

  @allowed_origins ["builtin", "custom"]
  @allowed_categories ["primitive", "navigation", "overlay", "visualization", "data", "runtime", "utility"]
  @allowed_state_models ["stateless", "stateful"]

  @enforce_keys [:widget_id, :origin, :category, :state_model, :props_schema, :event_schema, :version]
  defstruct [:widget_id, :origin, :category, :state_model, :props_schema, :event_schema, :version, capabilities: []]

  @type t :: %__MODULE__{
          widget_id: String.t(),
          origin: String.t(),
          category: String.t(),
          state_model: String.t(),
          props_schema: map(),
          event_schema: map(),
          version: String.t(),
          capabilities: [String.t()]
        }

  @spec validate(map() | t()) :: {:ok, t()} | {:error, TypedError.t()}
  def validate(%__MODULE__{} = descriptor), do: validate(Map.from_struct(descriptor))

  def validate(descriptor) when is_map(descriptor) do
    with {:ok, widget_id} <- validate_non_empty_string(descriptor, :widget_id, "widget_descriptor.invalid_widget_id"),
         {:ok, origin} <- validate_inclusion(descriptor, :origin, @allowed_origins, "widget_descriptor.invalid_origin"),
         {:ok, category} <-
           validate_inclusion(descriptor, :category, @allowed_categories, "widget_descriptor.invalid_category"),
         {:ok, state_model} <-
           validate_inclusion(descriptor, :state_model, @allowed_state_models, "widget_descriptor.invalid_state_model"),
         {:ok, props_schema} <- validate_map_field(descriptor, :props_schema, "widget_descriptor.invalid_props_schema"),
         {:ok, event_schema} <- validate_map_field(descriptor, :event_schema, "widget_descriptor.invalid_event_schema"),
         {:ok, version} <- validate_non_empty_string(descriptor, :version, "widget_descriptor.invalid_version"),
         {:ok, capabilities} <- validate_capabilities(descriptor) do
      {:ok,
       %__MODULE__{
         widget_id: widget_id,
         origin: origin,
         category: category,
         state_model: state_model,
         props_schema: props_schema,
         event_schema: event_schema,
         version: version,
         capabilities: capabilities
       }}
    end
  end

  def validate(_descriptor) do
    {:error,
     TypedError.new(
       "widget_descriptor.invalid_shape",
       "validation",
       false,
       %{reason: "descriptor must be a map"}
     )}
  end

  @spec allowed_categories() :: [String.t()]
  def allowed_categories, do: @allowed_categories

  @spec allowed_origins() :: [String.t()]
  def allowed_origins, do: @allowed_origins

  defp validate_non_empty_string(descriptor, key, error_code) do
    case fetch_any(descriptor, key) do
      value when is_binary(value) ->
        if String.trim(value) != "" do
          {:ok, value}
        else
          {:error, TypedError.new(error_code, "validation", false, %{field: key})}
        end

      _ -> {:error, TypedError.new(error_code, "validation", false, %{field: key})}
    end
  end

  defp validate_inclusion(descriptor, key, allowed, error_code) do
    case fetch_any(descriptor, key) do
      value when is_binary(value) ->
        if value in allowed do
          {:ok, value}
        else
          {:error, TypedError.new(error_code, "validation", false, %{field: key, value: value, allowed: allowed})}
        end

      value -> {:error, TypedError.new(error_code, "validation", false, %{field: key, value: value, allowed: allowed})}
    end
  end

  defp validate_map_field(descriptor, key, error_code) do
    case fetch_any(descriptor, key) do
      value when is_map(value) -> {:ok, value}
      _ -> {:error, TypedError.new(error_code, "validation", false, %{field: key})}
    end
  end

  defp validate_capabilities(descriptor) do
    case fetch_any(descriptor, :capabilities) do
      nil ->
        {:ok, []}

      caps when is_list(caps) ->
        if Enum.all?(caps, &is_binary/1) do
          {:ok, caps}
        else
          {:error,
           TypedError.new(
             "widget_descriptor.invalid_capabilities",
             "validation",
             false,
             %{field: :capabilities, required_shape: "list<string>"}
           )}
        end

      _ ->
        {:error,
         TypedError.new(
           "widget_descriptor.invalid_capabilities",
           "validation",
           false,
           %{field: :capabilities, required_shape: "list<string>"}
         )}
    end
  end

  defp fetch_any(map, key), do: Map.get(map, key) || Map.get(map, Atom.to_string(key))
end
