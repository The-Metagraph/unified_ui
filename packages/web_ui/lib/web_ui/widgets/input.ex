defmodule WebUi.Widgets.Input do
  @moduledoc """
  Baseline input widgets for direct-use `web_ui` forms.
  """

  alias WebUi.Widgets.Builder

  @kinds [:text_input, :checkbox, :select]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec text_input(String.t() | atom(), keyword() | map()) :: WebUi.Widget.t()
  def text_input(id, opts \\ []) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:text_input,
      id: id,
      attributes: %{
        name: Builder.option(opts, :name),
        value: Builder.option(opts, :value, ""),
        placeholder: Builder.option(opts, :placeholder),
        multiline: Builder.option(opts, :multiline, false),
        input_mode: Builder.option(opts, :input_mode, :text)
      },
      state: Builder.state(opts, [:disabled, :focused, :editing]),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_change: :change, on_focus: :focus, on_submit: :submit),
      metadata: Builder.metadata(opts, %{native_surface: :input})
    )
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword() | map()) :: WebUi.Widget.t()
  def checkbox(id, label, opts \\ []) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:checkbox,
      id: id,
      attributes: %{
        name: Builder.option(opts, :name),
        label: label,
        checked_value: Builder.option(opts, :checked_value, true),
        unchecked_value: Builder.option(opts, :unchecked_value, false)
      },
      state:
        Builder.state(opts, [:disabled, :focused, :checked])
        |> Map.put(:checked, Builder.option(opts, :checked, Builder.option(opts, :value, false))),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_change: :change, on_focus: :focus),
      metadata: Builder.metadata(opts, %{native_surface: :input})
    )
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def select(id, options, opts \\ []) when is_list(options) do
    opts = Builder.options(Map.put(Builder.options(opts), :id, id))

    Builder.widget(:select,
      id: id,
      attributes: %{
        name: Builder.option(opts, :name),
        value: Builder.option(opts, :value),
        multiple: Builder.option(opts, :multiple, false),
        options: normalize_options(options)
      },
      state: Builder.state(opts, [:disabled, :focused]),
      styles: Builder.styles(opts),
      events: Builder.events(opts, on_change: :change, on_focus: :focus),
      metadata: Builder.metadata(opts, %{native_surface: :input})
    )
  end

  defp normalize_options(options) do
    Enum.map(options, fn option ->
      option = Builder.options(option)

      %{}
      |> Builder.maybe_put(:id, Builder.option(option, :id))
      |> Builder.maybe_put(:value, Builder.option(option, :value))
      |> Builder.maybe_put(:label, Builder.option(option, :label))
      |> Builder.maybe_put(:description, Builder.option(option, :description))
      |> Builder.maybe_put(:disabled, Builder.option(option, :disabled))
      |> Builder.maybe_put(:selected, Builder.option(option, :selected))
    end)
  end
end
