defmodule TerminalUi.Widgets.Navigation do
  @moduledoc """
  Foundational navigation surfaces for `terminal_ui`.
  """

  alias TerminalUi.Widget
  alias TerminalUi.Widgets.Builder

  @spec kinds() :: [atom()]
  def kinds do
    [:tabs, :menu, :breadcrumbs, :list]
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Widget.new(:tabs,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :tabs], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Widget.new(:menu,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :menu], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec breadcrumbs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    Widget.new(:breadcrumbs,
      id: id,
      metadata: Builder.metadata(keyword_label(id, opts), Keyword.put(opts, :role, :breadcrumbs)),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(activate: opts[:on_follow]),
      styles: Builder.styles(opts)
    )
  end

  @spec list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Widget.new(:list,
      id: id,
      metadata:
        Builder.metadata(
          keyword_label(id, opts),
          Keyword.merge([focusable: true, role: :list], opts)
        ),
      state: Builder.state(opts, %{current: Keyword.get(opts, :current)}),
      bindings: Builder.bindings(opts, %{current: Keyword.get(opts, :binding)}),
      attributes: %{items: Builder.normalize_items(items)},
      events: Builder.events(navigation: opts[:on_navigate], select: opts[:on_select]),
      styles: Builder.styles(opts)
    )
  end

  @spec event_payload(keyword() | map()) :: map() | nil
  def event_payload(opts) when is_list(opts), do: opts |> Enum.into(%{}) |> event_payload()

  def event_payload(%{navigate_to: screen_id} = opts) when is_atom(screen_id) or is_binary(screen_id) do
    params = Map.get(opts, :navigate_params, %{})

    %{
      family: :navigation,
      intent: Map.get(opts, :intent, :navigate_to),
      target: %{navigation: %{action: :navigate_to, screen: screen_id, params: params}},
      payload: Map.get(opts, :payload, %{})
    }
  end

  def event_payload(%{replace_with: screen_id} = opts) when is_atom(screen_id) or is_binary(screen_id) do
    params = Map.get(opts, :navigate_params, %{})

    %{
      family: :navigation,
      intent: Map.get(opts, :intent, :replace_with),
      target: %{navigation: %{action: :replace_with, screen: screen_id, params: params}},
      payload: Map.get(opts, :payload, %{})
    }
  end

  def event_payload(%{go_back: true}) do
    %{
      family: :navigation,
      intent: :go_back,
      target: %{navigation: %{action: :go_back}},
      payload: %{}
    }
  end

  def event_payload(%{go_forward: true}) do
    %{
      family: :navigation,
      intent: :go_forward,
      target: %{navigation: %{action: :go_forward}},
      payload: %{}
    }
  end

  def event_payload(%{open_modal: modal_id} = opts) when is_atom(modal_id) or is_binary(modal_id) do
    params = Map.get(opts, :navigate_params, %{})

    %{
      family: :navigation,
      intent: Map.get(opts, :intent, :open_modal),
      target: %{navigation: %{action: :open_modal, modal: modal_id, params: params}},
      payload: Map.get(opts, :payload, %{})
    }
  end

  def event_payload(%{close_modal: true} = opts) do
    navigation =
      %{
        action: :close_modal
      }
      |> maybe_put(:modal, Map.get(opts, :modal))

    %{
      family: :navigation,
      intent: :close_modal,
      target: %{navigation: navigation},
      payload: %{}
    }
  end

  def event_payload(_opts), do: nil

  defp keyword_label(id, opts), do: Keyword.get(opts, :label, to_string(id))

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
