defmodule LiveUi.Demo.Style do
  @moduledoc """
  Shared canonical-first style helpers for the package-local `live_ui` demo.
  """

  @theme LiveUi.Theme.default()

  @spec shell() :: map()
  def shell do
    LiveUi.Style.component_assigns(:screen_shell,
      theme: @theme,
      variant: :workspace,
      style: %{spacing: %{gap: :lg}}
    )
  end

  @spec panel(keyword()) :: map()
  def panel(opts \\ []) do
    LiveUi.Style.component_assigns(:box,
      theme: @theme,
      variant: Keyword.get(opts, :variant, :panel),
      class: Keyword.get(opts, :class),
      style: merge_style(panel_style(), Keyword.get(opts, :style, %{}))
    )
  end

  @spec text(keyword()) :: map()
  def text(opts \\ []) do
    tone = Keyword.get(opts, :tone)

    LiveUi.Style.component_assigns(:text,
      theme: @theme,
      tone: tone,
      class: Keyword.get(opts, :class),
      style:
        merge_style(
          text_style(tone, Keyword.get(opts, :strong?, false)),
          Keyword.get(opts, :style, %{})
        )
    )
  end

  @spec button(keyword()) :: map()
  def button(opts \\ []) do
    variant = Keyword.get(opts, :variant, :solid)

    LiveUi.Style.component_assigns(:button,
      theme: @theme,
      variant: variant,
      state: Keyword.get(opts, :state),
      class: Keyword.get(opts, :class),
      style: merge_style(button_style(variant, opts), Keyword.get(opts, :style, %{}))
    )
  end

  @spec layout(atom(), keyword()) :: map()
  def layout(component, opts \\ []) do
    LiveUi.Style.component_assigns(component,
      theme: @theme,
      class: Keyword.get(opts, :class),
      style: Keyword.get(opts, :style, %{})
    )
  end

  defp panel_style do
    %{
      background: "#0b1220",
      border_color: "#22324b",
      border: %{radius: :xl, weight: :thin},
      spacing: %{gap: :md}
    }
  end

  defp text_style(tone, strong?) do
    %{}
    |> maybe_put(:foreground, text_color(tone))
    |> maybe_put(:text, if(strong?, do: %{bold?: true}, else: nil))
  end

  defp text_color(:accent), do: "#7dd3fc"
  defp text_color(:success), do: "#86efac"
  defp text_color(:warning), do: "#fde68a"
  defp text_color(:critical), do: "#fda4af"
  defp text_color(_other), do: "#cbd5e1"

  defp button_style(:quiet, opts) do
    base = %{
      background: "#0f1b2d",
      foreground: "#93c5fd",
      border_color: "#1d4ed8",
      border: %{radius: :full, weight: :thin},
      spacing: %{padding_x: :lg, padding_y: :sm}
    }

    maybe_full_width(base, opts)
  end

  defp button_style(_variant, opts) do
    base = %{
      background: "#1d4ed8",
      foreground: "#eff6ff",
      border_color: "#60a5fa",
      border: %{radius: :full, weight: :thin},
      spacing: %{padding_x: :lg, padding_y: :sm}
    }

    maybe_full_width(base, opts)
  end

  defp maybe_full_width(style, opts) do
    if Keyword.get(opts, :full_width?, false) do
      merge_style(style, %{
        sizing: %{width: :full},
        alignment: %{justify: :start},
        text: %{bold?: true}
      })
    else
      style
    end
  end

  defp merge_style(left, right) do
    Map.merge(left, right, fn _key, left_value, right_value ->
      if is_map(left_value) and is_map(right_value) do
        merge_style(left_value, right_value)
      else
        right_value
      end
    end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
