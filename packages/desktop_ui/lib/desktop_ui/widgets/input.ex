defmodule DesktopUi.Widgets.Input do
  @moduledoc """
  Foundational input widgets for direct-native `desktop_ui`.
  """

  alias DesktopUi.Widget

  @spec kinds() :: [atom()]
  def kinds do
    [:checkbox, :radio_group, :select, :text_input]
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Widget.new(:text_input,
      id: id,
      metadata: metadata(opts, role: :text_input),
      state: %{
        disabled: Keyword.get(opts, :disabled, false),
        focused: false,
        value: Keyword.get(opts, :value, "")
      },
      bindings: %{value: Keyword.get(opts, :binding, :value)},
      attributes: %{placeholder: Keyword.get(opts, :placeholder, "")},
      styles: styles(opts),
      events: %{
        change: Keyword.get(opts, :on_change, %{intent: :change_value}),
        submit: Keyword.get(opts, :on_submit, %{intent: :submit_value})
      }
    )
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Widget.new(:checkbox,
      id: id,
      metadata: metadata(opts, role: :checkbox),
      state: %{
        disabled: Keyword.get(opts, :disabled, false),
        focused: false,
        checked: Keyword.get(opts, :checked, false)
      },
      bindings: %{checked: Keyword.get(opts, :binding, :checked)},
      attributes: %{label: label},
      styles: styles(opts),
      events: %{
        change: Keyword.get(opts, :on_change, %{intent: :toggle_checked})
      }
    )
  end

  @spec radio_group(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Widget.new(:radio_group,
      id: id,
      metadata:
        metadata(opts,
          role: :radio_group,
          focus_group: Keyword.get(opts, :focus_group, "#{id}:radio_group"),
          binding_surface: :selection
        ),
      state: %{
        disabled: Keyword.get(opts, :disabled, false),
        focused: false,
        selected: Keyword.get(opts, :selected)
      },
      bindings: %{selected: Keyword.get(opts, :binding, :selected)},
      attributes: %{options: Enum.map(options, &Map.new/1)},
      styles: styles(opts),
      events: %{
        selection: Keyword.get(opts, :on_select, %{intent: :select_option})
      }
    )
  end

  @spec select(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Widget.new(:select,
      id: id,
      metadata:
        metadata(opts,
          role: :select,
          shortcut: Keyword.get(opts, :shortcut),
          binding_surface: :selection
        ),
      state: %{
        disabled: Keyword.get(opts, :disabled, false),
        focused: false,
        selected: Keyword.get(opts, :selected)
      },
      bindings: %{selected: Keyword.get(opts, :binding, :selected)},
      attributes: %{options: Enum.map(options, &Map.new/1), current: Keyword.get(opts, :selected)},
      styles: styles(opts),
      events:
        %{
          selection: Keyword.get(opts, :on_select, %{intent: :select_option}),
          shortcut:
            shortcut_payload(
              Keyword.get(opts, :shortcut),
              Keyword.get(opts, :shortcut_intent, :open_select)
            )
        }
        |> Enum.reject(fn {_key, value} -> is_nil(value) end)
        |> Map.new()
    )
  end

  defp metadata(opts, defaults) do
    defaults
    |> Keyword.merge(
      focusable: true,
      shortcut_scope: Keyword.get(opts, :shortcut_scope, :screen)
    )
    |> Keyword.merge(Keyword.get(opts, :metadata, []))
    |> Map.new()
  end

  defp styles(opts), do: Map.new(Keyword.get(opts, :styles, []))

  defp shortcut_payload(nil, _intent), do: nil

  defp shortcut_payload(shortcut, intent) do
    %{key: shortcut, intent: intent}
  end
end
