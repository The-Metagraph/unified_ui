defmodule WebUi.Frontend.Model do
  @moduledoc """
  Frontend-side model for the scaffolded Elm runtime contract.
  """

  alias WebUi.Frontend.Error
  alias WebUi.Widget

  @enforce_keys [:screen_id, :title, :widgets, :widget_summaries, :bridge, :server_revision]
  defstruct [
    :screen_id,
    :title,
    :widgets,
    :widget_summaries,
    :bridge,
    :server_revision,
    local_state: %{},
    status: :hydrated
  ]

  @type status :: :hydrated | :dirty

  @type t :: %__MODULE__{
          screen_id: atom(),
          title: String.t(),
          widgets: [Widget.t()],
          widget_summaries: [map()],
          bridge: map(),
          server_revision: non_neg_integer(),
          local_state: map(),
          status: status()
        }

  @spec new(map()) :: {:ok, t()} | {:error, Error.t()}
  def new(%{
        screen: %{id: screen_id, title: title},
        widgets: widgets,
        widget_summaries: widget_summaries,
        bridge: bridge,
        revision: revision
      })
      when is_atom(screen_id) and is_binary(title) and is_list(widgets) and
             is_list(widget_summaries) and is_map(bridge) and is_integer(revision) do
    {:ok,
     %__MODULE__{
       screen_id: screen_id,
       title: title,
       widgets: widgets,
       widget_summaries: widget_summaries,
       bridge: bridge,
       server_revision: revision
     }}
  end

  def new(other), do: {:error, Error.invalid_hydration_payload(other)}

  @spec put_local(t(), atom(), term()) :: {:ok, t()} | {:error, Error.t()}
  def put_local(%__MODULE__{} = model, key, value) when is_atom(key) do
    local_state = Map.put(model.local_state, key, value)

    if is_map(local_state) do
      {:ok, %{model | local_state: local_state, status: :dirty}}
    else
      {:error, Error.invalid_local_state(local_state)}
    end
  end
end
