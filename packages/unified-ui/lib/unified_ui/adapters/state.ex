defmodule UnifiedUi.Adapters.State do
  @moduledoc """
  Renderer state management for tracking platform widgets and metadata.

  This module defines the `RendererState` struct that all renderers should
  use (or extend) to track their platform-specific state. It provides
  utilities for managing widget registries, tracking lifecycle, and
  maintaining renderer configuration.

  ## RendererState Struct

  The `RendererState` struct contains:

  * `:platform` - Atom identifying the platform (:terminal, :desktop, :web)
  * `:root` - Reference to the root platform widget
  * `:widgets` - Map of element ID to platform widget references
  * `:version` - Monotonically increasing version for change tracking
  * `:config` - Renderer configuration options
  * `:metadata` - Arbitrary metadata storage

  ## Example

      # Create a new renderer state
      state = RendererState.new(:terminal, window_pid: self())

      # Register a widget
      state = RendererState.put_widget(state, :submit_button, button_pid)

      # Lookup a widget
      {:ok, pid} = RendererState.get_widget(state, :submit_button)

      # Update version
      state = RendererState.bump_version(state)

  """

  @type platform :: :terminal | :desktop | :web
  @type widget_ref :: term()
  @type widget_map :: %{atom() => widget_ref()}
  @type config :: keyword()
  @type metadata :: map()

  defstruct [
    :platform,
    :root,
    widgets: %{},
    version: 1,
    config: [],
    metadata: %{}
  ]

  @type t :: %__MODULE__{
          platform: platform() | nil,
          root: widget_ref() | nil,
          widgets: widget_map(),
          version: pos_integer(),
          config: config(),
          metadata: metadata()
        }

  # Exception definitions

  defmodule StateError do
    @moduledoc """
    Exception raised when an operation on renderer state fails.

    ## Exception Fields

    * `:message` - Human-readable error message
    * `:reason` - Atom describing the error reason
    * `:id` - Widget ID (for widget-related errors)

    ## Examples

        raise StateError, reason: :no_root_widget
        raise StateError, reason: :widget_not_found, id: :my_button

    """
    defexception [:message, :reason, :id]

    @impl true
    @spec exception(keyword()) :: %__MODULE__{}
    def exception(opts) do
      reason = Keyword.get(opts, :reason)
      id = Keyword.get(opts, :id)

      message = build_message(reason, id)
      %__MODULE__{message: message, reason: reason, id: id}
    end

    @impl true
    @spec message(%__MODULE__{}) :: String.t()
    def message(%__MODULE__{} = exception) do
      exception.message
    end

    defp build_message(:no_root_widget, nil) do
      "No root widget set in renderer state"
    end

    defp build_message(:widget_not_found, id) when is_atom(id) do
      "No widget found for ID #{inspect(id)}"
    end

    defp build_message(:widget_not_found, nil) do
      "No widget found for the given ID"
    end

    defp build_message(reason, _id) do
      "Renderer state error: #{inspect(reason)}"
    end
  end

  @doc """
  Creates a new renderer state for the given platform.

  ## Parameters

  * `platform` - The platform atom (:terminal, :desktop, :web)
  * `opts` - Optional configuration:
    * `:root` - Root widget reference
    * `:widgets` - Initial widget map
    * `:config` - Renderer configuration

  ## Returns

  A new `RendererState` struct.

  ## Examples

      iex> RendererState.new(:terminal)
      %RendererState{platform: :terminal, version: 1}

      iex> RendererState.new(:desktop, root: window_pid)
      %RendererState{platform: :desktop, root: window_pid}

  """
  @spec new(platform(), keyword()) :: t()
  def new(platform, opts \\ []) when is_atom(platform) do
    %__MODULE__{
      platform: platform,
      root: Keyword.get(opts, :root),
      widgets: Keyword.get(opts, :widgets, %{}),
      config: Keyword.get(opts, :config, []),
      metadata: Keyword.get(opts, :metadata, %{})
    }
  end

  @doc """
  Sets the root widget reference.

  ## Examples

      iex> state |> RendererState.put_root(window_pid)
      %RendererState{root: window_pid}

  """
  @spec put_root(t(), widget_ref()) :: t()
  def put_root(%__MODULE__{} = state, root) do
    %{state | root: root}
  end

  @doc """
  Gets the root widget reference.

  Returns `{:ok, widget}` or `:error` if no root is set.

  ## Examples

      iex> RendererState.get_root(state)
      {:ok, #PID<0.123.0>}

      iex> RendererState.get_root(%RendererState{})
      :error

  """
  @spec get_root(t()) :: {:ok, widget_ref()} | :error
  def get_root(%__MODULE__{root: nil}), do: :error
  def get_root(%__MODULE__{root: root}), do: {:ok, root}

  @doc """
  Gets the root widget, raising if not set.

  ## Examples

      iex> RendererState.get_root!(state)
      #PID<0.123.0>

  """
  @spec get_root!(t()) :: widget_ref()
  def get_root!(%__MODULE__{} = state) do
    case get_root(state) do
      {:ok, root} -> root
      :error -> raise StateError, reason: :no_root_widget
    end
  end

  @doc """
  Registers a widget reference for an element ID.

  ## Examples

      iex> RendererState.put_widget(state, :submit_button, button_pid)
      %RendererState{widgets: %{submit_button: #PID<0.123.0>}}

  """
  @spec put_widget(t(), atom(), widget_ref()) :: t()
  def put_widget(%__MODULE__{} = state, id, widget) when is_atom(id) do
    %{state | widgets: Map.put(state.widgets, id, widget)}
  end

  @doc """
  Gets a widget reference by element ID.

  Returns `{:ok, widget}` or `:error` if not found.

  ## Examples

      iex> RendererState.get_widget(state, :submit_button)
      {:ok, #PID<0.123.0>}

      iex> RendererState.get_widget(state, :nonexistent)
      :error

  """
  @spec get_widget(t(), atom()) :: {:ok, widget_ref()} | :error
  def get_widget(%__MODULE__{} = state, id) when is_atom(id) do
    case Map.fetch(state.widgets, id) do
      {:ok, widget} -> {:ok, widget}
      :error -> :error
    end
  end

  @doc """
  Gets a widget by ID, raising if not found.

  ## Examples

      iex> RendererState.get_widget!(state, :submit_button)
      #PID<0.123.0>

  """
  @spec get_widget!(t(), atom()) :: widget_ref()
  def get_widget!(%__MODULE__{} = state, id) do
    case get_widget(state, id) do
      {:ok, widget} -> widget
      :error -> raise StateError, reason: :widget_not_found, id: id
    end
  end

  @doc """
  Removes a widget reference from the registry.

  ## Examples

      iex> RendererState.delete_widget(state, :submit_button)
      %RendererState{widgets: %{}}

  """
  @spec delete_widget(t(), atom()) :: t()
  def delete_widget(%__MODULE__{} = state, id) when is_atom(id) do
    %{state | widgets: Map.delete(state.widgets, id)}
  end

  @doc """
  Checks if a widget is registered for the given ID.

  ## Examples

      iex> RendererState.has_widget?(state, :submit_button)
      true

      iex> RendererState.has_widget?(state, :nonexistent)
      false

  """
  @spec has_widget?(t(), atom()) :: boolean()
  def has_widget?(%__MODULE__{} = state, id) when is_atom(id) do
    Map.has_key?(state.widgets, id)
  end

  @doc """
  Returns all registered widget IDs.

  ## Examples

      iex> RendererState.widget_ids(state)
      [:submit_button, :cancel_button, :email_input]

  """
  @spec widget_ids(t()) :: [atom()]
  def widget_ids(%__MODULE__{} = state) do
    Map.keys(state.widgets)
  end

  @doc """
  Returns the count of registered widgets.

  ## Examples

      iex> RendererState.widget_count(state)
      3

  """
  @spec widget_count(t()) :: non_neg_integer()
  def widget_count(%__MODULE__{} = state) do
    map_size(state.widgets)
  end

  @doc """
  Increments the version counter.

  The version is used to track changes to the rendered state.

  ## Examples

      iex> RendererState.bump_version(%RendererState{version: 1})
      %RendererState{version: 2}

  """
  @spec bump_version(t()) :: t()
  def bump_version(%__MODULE__{} = state) do
    %{state | version: state.version + 1}
  end

  @doc """
  Gets a configuration value.

  ## Examples

      iex> RendererState.get_config(state, :window_title)
      "My App"

      iex> RendererState.get_config(state, :nonexistent, :default)
      :default

  """
  @spec get_config(t(), atom(), term()) :: term()
  def get_config(%__MODULE__{} = state, key, default \\ nil) do
    Keyword.get(state.config, key, default)
  end

  @doc """
  Sets a configuration value.

  Returns a new state with the updated config.

  ## Examples

      iex> RendererState.put_config(state, :window_title, "My App")
      %RendererState{config: [window_title: "My App"]}

  """
  @spec put_config(t(), atom(), term()) :: t()
  def put_config(%__MODULE__{} = state, key, value) do
    %{state | config: Keyword.put(state.config, key, value)}
  end

  @doc """
  Gets metadata value.

  ## Examples

      iex> RendererState.get_metadata(state, :last_render_time)
      123_456

  """
  @spec get_metadata(t(), atom(), term()) :: term()
  def get_metadata(%__MODULE__{} = state, key, default \\ nil) do
    Map.get(state.metadata, key, default)
  end

  @doc """
  Sets metadata value.

  ## Examples

      iex> RendererState.put_metadata(state, :last_render_time, 123_456)
      %RendererState{metadata: %{last_render_time: 123_456}}

  """
  @spec put_metadata(t(), atom(), term()) :: t()
  def put_metadata(%__MODULE__{} = state, key, value) do
    %{state | metadata: Map.put(state.metadata, key, value)}
  end

  @doc """
  Returns a list of all widget references.

  ## Examples

      iex> RendererState.all_widgets(state)
      [#PID<0.123.0>, #PID<0.124.0>, #PID<0.125.0>]

  """
  @spec all_widgets(t()) :: [widget_ref()]
  def all_widgets(%__MODULE__{} = state) do
    Map.values(state.widgets)
  end

  @doc """
  Creates a map of element IDs to widget references.

  ## Examples

      iex> RendererState.to_map(state)
      %{submit_button: #PID<0.123.0>, cancel_button: #PID<0.124.0>}

  """
  @spec to_map(t()) :: widget_map()
  def to_map(%__MODULE__{} = state) do
    state.widgets
  end

  @doc """
  Checks if the state is for the given platform.

  ## Examples

      iex> RendererState.platform?(state, :terminal)
      true

      iex> RendererState.platform?(state, :desktop)
      false

  """
  @spec platform?(t(), platform()) :: boolean()
  def platform?(%__MODULE__{platform: platform}, platform) when is_atom(platform), do: true
  def platform?(%__MODULE__{}, _platform), do: false
end
