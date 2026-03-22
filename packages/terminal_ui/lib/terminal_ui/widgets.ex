defmodule TerminalUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for foundational native `terminal_ui` widgets.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.{Builder, Foundational, Input, Navigation}

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
    [__MODULE__, Widget, Foundational, Input, Navigation]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [
      Foundational.kinds(),
      Input.kinds(),
      Navigation.kinds(),
      [:container, :column, :row, :stack, :dialog]
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
      widget_contract: :ready,
      registration_surface: :ready,
      direct_native_scaffold: :ready,
      foundational_content_widgets: :ready,
      foundational_action_widgets: :ready,
      foundational_form_widgets: :ready,
      foundational_navigation_widgets: :ready,
      focus_and_shortcut_metadata: :ready
    }
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

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Foundational.spacer(id, opts)
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Foundational.separator(id, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Foundational.button(id, label, opts)
  end

  @spec toggle(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toggle(id, label, opts \\ []) do
    Foundational.toggle(id, label, opts)
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, target, opts \\ []) do
    Foundational.link(id, label, target, opts)
  end

  @spec command(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def command(id, label, opts \\ []) do
    Foundational.command(id, label, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Input.text_input(id, opts)
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Input.checkbox(id, label, opts)
  end

  @spec radio_group(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Input.radio_group(id, options, opts)
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Input.select(id, options, opts)
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Navigation.tabs(id, items, opts)
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Navigation.menu(id, items, opts)
  end

  @spec breadcrumbs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    Navigation.breadcrumbs(id, items, opts)
  end

  @spec list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Navigation.list(id, items, opts)
  end

  @spec container(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def container(id, children, opts \\ []) do
    Widget.new(:container,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec column(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def column(id, children, opts \\ []) do
    Widget.new(:column,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{gap: Keyword.get(opts, :gap, :sm)},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec row(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def row(id, children, opts \\ []) do
    Widget.new(:row,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{gap: Keyword.get(opts, :gap, :sm), direction: :horizontal},
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children, opts \\ []) do
    Widget.new(:stack,
      id: id,
      family: :layout,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      attributes: %{
        gap: Keyword.get(opts, :gap, :sm),
        stacking: Keyword.get(opts, :stacking, :overlay)
      },
      slot_children: %{default: children},
      styles: Builder.styles(opts)
    )
  end

  @spec dialog(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, children, opts \\ []) do
    Widget.new(:dialog,
      id: id,
      family: :feedback,
      metadata: %{label: Keyword.get(opts, :label, to_string(id)), native_surface: true},
      state: Builder.state(opts, %{open: Keyword.get(opts, :open, true)}),
      slot_children: %{content: children},
      events: Builder.events(dismiss: opts[:on_dismiss]),
      styles: Builder.styles(opts)
    )
  end
end
