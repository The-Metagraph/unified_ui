defmodule WebUi.Widgets.Native.Widget do
  @moduledoc """
  Base behavior for native web_ui widgets.

  This module defines the contract that all native web_ui widgets
  must implement. Native widgets are renderer-native components
  that work directly with the Phoenix + Elm runtime.

  ## Required Callbacks

  * `id/0` - Unique widget identifier
  * `metadata/0` - Widget metadata (name, family, version)
  * `props_schema/0` - Schema for widget properties
  * `render_server/2` - Server-side rendering function
  * `render_frontend/2` - Frontend (Elm) rendering specification
  * `default_state/0` - Default widget state

  ## Optional Callbacks

  * `handle_event/3` - Event handling
  * `state_schema/0` - Widget state schema
  * `style_schema/0` - Widget styling schema
  """

  @type widget_id :: atom()
  @type widget_name :: String.t()
  @type widget_family :: atom()
  @type props :: map()
  @type state :: map()
  @type slot :: %{optional(atom()) => [t()]}

  @type metadata :: %{
          id: widget_id(),
          name: widget_name(),
          family: widget_family(),
          version: String.t()
        }

  @type t :: %__MODULE__{
          id: widget_id(),
          metadata: metadata(),
          props: props(),
          state: state(),
          slots: slot()
        }

  defstruct [:id, :metadata, :props, :state, :slots]

  @doc """
  Returns the unique widget identifier.
  """
  @callback id() :: widget_id()

  @doc """
  Returns widget metadata.
  """
  @callback metadata() :: metadata()

  @doc """
  Returns the schema for widget properties.
  """
  @callback props_schema() :: map()

  @doc """
  Renders the widget on the server side.
  """
  @callback render_server(props(), keyword()) :: Phoenix.HTML.safe()

  @doc """
  Returns the frontend (Elm) rendering specification.
  """
  @callback render_frontend(props(), keyword()) :: map()

  @doc """
  Returns the default widget state.
  """
  @callback default_state() :: state()

  @doc """
  Optional: Handles widget events.
  """
  @callback handle_event(atom(), map(), state()) :: {:ok, state()} | {:error, term()}

  @doc """
  Optional: Returns the widget state schema.
  """
  @callback state_schema() :: map()

  @doc """
  Optional: Returns the widget styling schema.
  """
  @callback style_schema() :: map()

  @optional_callbacks [
    handle_event: 3,
    state_schema: 0,
    style_schema: 0
  ]

  @doc """
  Macro for using the Widget behavior in a widget module.
  """
  defmacro __using__(_opts) do
    quote do
      @behaviour WebUi.Widgets.Native.Widget
      import WebUi.Widgets.Native.Widget, only: [defwidget: 1]
    end
  end

  @doc """
  Convenience macro for defining a widget with defaults.
  """
  defmacro defwidget(block) do
    quote do
      unquote(block)
    end
  end

  @spec validate_props(module(), props()) :: :ok | {:error, term()}
  def validate_props(widget_module, props) when is_atom(widget_module) and is_map(props) do
    schema = widget_module.props_schema()

    Enum.reduce_while(props, :ok, fn {key, value}, _acc ->
      case Map.get(schema, key) do
        nil ->
          {:halt, {:error, {:unknown_prop, key}}}

        validator when is_function(validator, 1) ->
          case validator.(value) do
            :ok -> {:cont, :ok}
            error -> {:halt, error}
          end

        _type ->
          {:cont, :ok}
      end
    end)
  end

  @spec validate_state(module(), state()) :: :ok | {:error, term()}
  def validate_state(widget_module, state) when is_atom(widget_module) and is_map(state) do
    if function_exported?(widget_module, :state_schema, 0) do
      schema = widget_module.state_schema()

      Enum.reduce_while(state, :ok, fn {key, value}, _acc ->
        case Map.get(schema, key) do
          nil ->
            {:halt, {:error, {:unknown_state_key, key}}}

          validator when is_function(validator, 1) ->
            case validator.(value) do
              :ok -> {:cont, :ok}
              error -> {:halt, error}
            end

          _type ->
            {:cont, :ok}
        end
      end)
    else
      :ok
    end
  end

  @spec create(module(), props(), keyword()) :: {:ok, t()} | {:error, term()}
  def create(widget_module, props, opts \\ []) when is_atom(widget_module) and is_map(props) do
    with :ok <- validate_props(widget_module, props),
         metadata when is_map(metadata) <- widget_module.metadata() do
      initial_state = Keyword.get(opts, :state, widget_module.default_state())
      slots = Keyword.get(opts, :slots, %{})

      {:ok,
       %__MODULE__{
         id: widget_module.id(),
         metadata: metadata,
         props: props,
         state: initial_state,
         slots: slots
       }}
    end
  end
end
