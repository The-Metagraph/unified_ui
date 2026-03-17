defmodule WebUi.Widgets.Input do
  @moduledoc """
  Baseline input widgets for direct-use `web_ui` forms.
  """

  alias WebUi.Widgets.Builder

  @kinds [:text_input, :checkbox, :select]

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec text_input(keyword() | map()) :: WebUi.Widget.t()
  def text_input(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:text_input,
      id: Builder.require_id!(opts, :text_input),
      props: %{
        name: Builder.option(opts, :name),
        value: Builder.option(opts, :value, ""),
        placeholder: Builder.option(opts, :placeholder),
        multiline?: Builder.option(opts, :multiline?, false),
        input_mode: Builder.option(opts, :input_mode, :text)
      },
      state: Builder.state(opts, [:disabled?, :focused?, :editing?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, change: :change, focus: :focus, submit: :submit),
      metadata: Builder.metadata(opts, %{native_surface: :input})
    )
  end

  @spec checkbox(keyword() | map()) :: WebUi.Widget.t()
  def checkbox(opts \\ []) do
    opts = Builder.options(opts)

    Builder.widget(:checkbox,
      id: Builder.require_id!(opts, :checkbox),
      props: %{
        name: Builder.option(opts, :name),
        label: Builder.option(opts, :label),
        checked_value: Builder.option(opts, :checked_value, true),
        unchecked_value: Builder.option(opts, :unchecked_value, false)
      },
      state:
        Builder.state(opts, [:disabled?, :focused?, :checked?])
        |> Map.put(
          :checked?,
          Builder.option(opts, :checked?, Builder.option(opts, :value, false))
        ),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, change: :change, focus: :focus),
      metadata: Builder.metadata(opts, %{native_surface: :input})
    )
  end

  @spec select([keyword() | map()], keyword() | map()) :: WebUi.Widget.t()
  def select(options, opts \\ []) when is_list(options) do
    opts = Builder.options(opts)

    Builder.widget(:select,
      id: Builder.require_id!(opts, :select),
      props: %{
        name: Builder.option(opts, :name),
        value: Builder.option(opts, :value),
        multiple?: Builder.option(opts, :multiple?, false),
        options: normalize_options(options)
      },
      state: Builder.state(opts, [:disabled?, :focused?]),
      style_hooks: Builder.style_hooks(opts),
      events: Builder.events(opts, change: :change, focus: :focus),
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
      |> Builder.maybe_put(:disabled?, Builder.option(option, :disabled?))
      |> Builder.maybe_put(:selected?, Builder.option(option, :selected?))
    end)
  end
end
