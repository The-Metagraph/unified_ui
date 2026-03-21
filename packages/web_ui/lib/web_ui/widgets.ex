defmodule WebUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for the native `web_ui` widget surface.
  """

  alias WebUi.Widget
  alias WebUi.Widgets.{Forms, Foundational, Input, Layout, Navigation}

  @type family :: Widget.family()

  @spec families() :: [family()]
  def families do
    kinds()
    |> Enum.map(&family_for_kind/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [Widget, Foundational, Input, Navigation, Layout, Forms]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [
      Foundational.kinds(),
      Input.kinds(),
      Navigation.kinds(),
      Layout.kinds(),
      Forms.kinds()
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec family_for_kind(atom() | String.t()) :: family()
  def family_for_kind(kind) when is_binary(kind),
    do: kind |> String.to_atom() |> family_for_kind()

  def family_for_kind(kind), do: Widget.family_for(kind)

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_definition: :ready,
      family_catalog: :ready,
      metadata_contract: :ready,
      foundational_widgets: :ready,
      input_widgets: :ready,
      navigation_widgets: :ready,
      form_composition: :ready,
      layout_primitives: :ready
    }
  end

  @spec widget(atom() | String.t(), keyword() | map()) :: Widget.t()
  def widget(kind, attrs \\ [])
  def widget(kind, attrs) when is_binary(kind), do: widget(String.to_atom(kind), attrs)
  def widget(kind, attrs), do: Widget.new(kind, attrs)

  @spec normalize(Widget.t() | map() | keyword()) :: {:ok, Widget.t()} | {:error, term()}
  def normalize(%Widget{} = widget), do: {:ok, widget}

  def normalize(attrs) when is_map(attrs) or is_list(attrs) do
    attrs = normalize_map(attrs)

    case {Map.fetch(attrs, :kind), Map.fetch(attrs, :id)} do
      {{:ok, kind}, {:ok, _id}} ->
        {:ok, Widget.new(kind, attrs)}

      _other ->
        {:error, :invalid_widget}
    end
  end

  @spec normalize_many([Widget.t() | map() | keyword()]) :: {:ok, [Widget.t()]} | {:error, term()}
  def normalize_many(widgets) when is_list(widgets) do
    widgets
    |> Enum.reduce_while({:ok, []}, fn widget, {:ok, acc} ->
      case normalize(widget) do
        {:ok, normalized} -> {:cont, {:ok, [normalized | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, normalized} -> {:ok, Enum.reverse(normalized)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Foundational.text(id, content, opts)
  end

  @spec label(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def label(id, content, opts \\ []) do
    Foundational.label(id, content, opts)
  end

  @spec icon(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def icon(id, name, opts \\ []) do
    Foundational.icon(id, name, opts)
  end

  @spec image(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def image(id, src, opts \\ []) do
    Foundational.image(id, src, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Foundational.button(id, label, opts)
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, href, opts \\ []) do
    Foundational.link(id, label, href, opts)
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Foundational.separator(id, opts)
  end

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Foundational.spacer(id, opts)
  end

  @spec content(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def content(id, children, opts \\ []) do
    Foundational.content(id, children, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Input.text_input(id, opts)
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Input.checkbox(id, label, opts)
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Input.select(id, options, opts)
  end

  @spec field(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def field(id, control, opts \\ []) do
    Forms.field(id, control, opts)
  end

  @spec field_group(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def field_group(id, children, opts \\ []) do
    Forms.field_group(id, children, opts)
  end

  @spec form(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def form(id, children, opts \\ []) do
    Forms.form(id, children, opts)
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children, opts \\ []) do
    Layout.stack(id, children, opts)
  end

  @spec panel(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def panel(id, title, children, opts \\ []) do
    Layout.panel(id, title, children, opts)
  end

  @spec row(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def row(id, children, opts \\ []) do
    Layout.row(id, children, opts)
  end

  @spec column(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def column(id, children, opts \\ []) do
    Layout.column(id, children, opts)
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Navigation.menu(id, items, opts)
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Navigation.tabs(id, items, opts)
  end

  @spec screen(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: map()
  def screen(id, title, children, opts \\ []) do
    %{
      id: id,
      title: title,
      root:
        stack("#{id}-root", children, direction: :column, styles: Keyword.get(opts, :styles, %{})),
      metadata: %{
        bridge: Keyword.get(opts, :bridge, :phoenix_elm),
        source: Keyword.get(opts, :source, :native)
      }
    }
  end

  defp normalize_map(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {normalize_key(key), value} end)
  end

  defp normalize_map(list) when is_list(list), do: list |> Enum.into(%{}) |> normalize_map()

  defp normalize_key("id"), do: :id
  defp normalize_key("family"), do: :family
  defp normalize_key("kind"), do: :kind
  defp normalize_key("metadata"), do: :metadata
  defp normalize_key("state"), do: :state
  defp normalize_key("slots"), do: :slots
  defp normalize_key("slot_children"), do: :slot_children
  defp normalize_key("attributes"), do: :attributes
  defp normalize_key("styles"), do: :styles
  defp normalize_key("events"), do: :events
  defp normalize_key("children"), do: :children
  defp normalize_key(key), do: key
end
