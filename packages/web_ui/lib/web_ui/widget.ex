defmodule WebUi.Widget do
  @moduledoc """
  Baseline native widget definition for the scaffolded `web_ui` package.
  """

  @enforce_keys [:id, :family, :kind]
  defstruct [
    :id,
    :family,
    :kind,
    props: %{},
    slots: %{},
    state: %{},
    style_hooks: [],
    events: %{},
    metadata: %{}
  ]

  @type family ::
          :foundational
          | :input
          | :navigation
          | :layout
          | :layer
          | :data
          | :feedback
          | :visualization
          | :operational
          | :unknown

  @type t :: %__MODULE__{
          id: String.t() | atom(),
          family: family(),
          kind: atom() | String.t(),
          props: map(),
          slots: map(),
          state: map(),
          style_hooks: [atom() | String.t()],
          events: map(),
          metadata: map()
        }

  @spec new(atom() | String.t(), keyword() | map()) :: t()
  def new(kind, attrs \\ []) when is_atom(kind) or is_binary(kind) do
    attrs = normalize_attrs(attrs)
    kind = normalize_kind(kind)

    %__MODULE__{
      id: Map.fetch!(attrs, :id),
      family: Map.get(attrs, :family, WebUi.Widgets.family_for_kind(kind)),
      kind: kind,
      props: normalize_map(Map.get(attrs, :props, %{})),
      slots: normalize_map(Map.get(attrs, :slots, %{})),
      state: normalize_map(Map.get(attrs, :state, %{})),
      style_hooks: normalize_style_hooks(Map.get(attrs, :style_hooks, [])),
      events: normalize_map(Map.get(attrs, :events, %{})),
      metadata: normalize_map(Map.get(attrs, :metadata, %{}))
    }
  end

  @spec summary(t()) :: map()
  def summary(%__MODULE__{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      event_names: widget.events |> Map.keys() |> Enum.sort(),
      slot_names: widget.slots |> Map.keys() |> Enum.sort(),
      style_hooks: Enum.sort_by(widget.style_hooks, &to_string/1)
    }
  end

  defp normalize_attrs(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {normalize_key(key), value} end)
  end

  defp normalize_attrs(list) when is_list(list), do: list |> Enum.into(%{}) |> normalize_attrs()
  defp normalize_attrs(_other), do: %{}

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})
  defp normalize_map(_other), do: %{}

  defp normalize_style_hooks(hooks) when is_list(hooks), do: hooks
  defp normalize_style_hooks(nil), do: []
  defp normalize_style_hooks(other), do: [other]

  defp normalize_kind(kind) when is_atom(kind), do: kind

  defp normalize_kind(kind) when is_binary(kind) do
    Enum.find(WebUi.Widgets.kinds(), kind, fn candidate ->
      Atom.to_string(candidate) == kind
    end)
  end

  defp normalize_key("id"), do: :id
  defp normalize_key("family"), do: :family
  defp normalize_key("kind"), do: :kind
  defp normalize_key("props"), do: :props
  defp normalize_key("slots"), do: :slots
  defp normalize_key("state"), do: :state
  defp normalize_key("style_hooks"), do: :style_hooks
  defp normalize_key("events"), do: :events
  defp normalize_key("metadata"), do: :metadata
  defp normalize_key(key), do: key
end
