defmodule LiveUi.Runtime.Model do
  @moduledoc """
  Shared runtime state owned by the internal LiveView engine.
  """

  alias Jido.Signal
  alias LiveUi.Descriptor
  alias LiveUi.Source

  @type status :: :initializing | :ready | :error

  @enforce_keys [:runtime_context, :source]
  defstruct [
    :descriptor_tree,
    :error,
    :iur_tree,
    :last_event,
    :last_signal,
    :render_metadata,
    :runtime_context,
    :screen_state,
    :signal_bindings,
    :source,
    :widget_state,
    status: :initializing,
    event_count: 0
  ]

  @type t :: %__MODULE__{
          descriptor_tree: Descriptor.t() | nil,
          error: Exception.t() | nil,
          iur_tree: term(),
          last_event: map() | nil,
          last_signal: Signal.t() | nil,
          render_metadata: map(),
          runtime_context: map(),
          screen_state: map() | nil,
          signal_bindings: [map()],
          source: Source.t(),
          widget_state: map(),
          status: status(),
          event_count: non_neg_integer()
        }

  @spec new(keyword()) :: t()
  def new(attrs) when is_list(attrs) do
    struct!(__MODULE__, attrs)
  end
end
