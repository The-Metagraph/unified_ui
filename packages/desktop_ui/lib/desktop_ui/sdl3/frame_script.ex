defmodule DesktopUi.Sdl3.FrameScript do
  @moduledoc """
  Visible-frame script export for the compiled SDL3 host runner.
  """

  alias DesktopUi.Sdl3.RenderPlan

  @spec contract() :: map()
  def contract do
    %{
      format: :tab_separated_key_values,
      header: "DESKTOP_UI_SDL3_FRAME",
      version: 1,
      preserves: [:window_titles, :logical_bounds, :draw_kinds, :resolved_styles, :clip_flags],
      target: :compiled_visible_runner
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :frame_script_ready

  @spec encode(RenderPlan.t()) :: {:ok, String.t()}
  def encode(%RenderPlan{} = plan) do
    lines =
      [
        encode_line("DESKTOP_UI_SDL3_FRAME", version: 1),
        encode_line("RUNTIME", runtime_id: plan.runtime_id, screen_id: plan.screen_id)
      ] ++
        Enum.flat_map(plan.windows, &encode_window_lines/1)

    {:ok, Enum.join(lines, "\n") <> "\n"}
  end

  @spec write(RenderPlan.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def write(%RenderPlan{} = plan, path) when is_binary(path) do
    with {:ok, script} <- encode(plan),
         :ok <- File.write(path, script) do
      {:ok, path}
    end
  end

  defp encode_window_lines(window) do
    window_line =
      encode_line("WINDOW",
        window_id: window.window_id,
        title: window.title,
        role: window.role,
        x: get_in(window, [:logical_bounds, :x]),
        y: get_in(window, [:logical_bounds, :y]),
        width: get_in(window, [:logical_bounds, :width]),
        height: get_in(window, [:logical_bounds, :height]),
        units: get_in(window, [:logical_bounds, :units])
      )

    draw_lines =
      Enum.map(window.draw_operations, fn operation ->
        encode_line("DRAW",
          window_id: window.window_id,
          order: operation[:order] || 0,
          widget_id: operation.widget_id,
          kind: operation.kind,
          family: operation.family,
          draw_kind: operation.draw_kind,
          x: get_in(operation, [:logical_bounds, :x]),
          y: get_in(operation, [:logical_bounds, :y]),
          width: get_in(operation, [:logical_bounds, :width]),
          height: get_in(operation, [:logical_bounds, :height]),
          units: get_in(operation, [:logical_bounds, :units]),
          clip: operation.clip?,
          bg: get_in(operation, [:resolved_styles, :bg]),
          variant: get_in(operation, [:resolved_styles, :variant]),
          layer_role: operation.layer_role,
          content: operation.content
        )
      end)

    [window_line | draw_lines]
  end

  defp encode_line(tag, attrs) do
    encoded_attrs =
      attrs
      |> Enum.flat_map(fn
        {_key, nil} -> []
        {_key, []} -> []
        {key, value} -> ["#{key}=#{URI.encode_www_form(to_string(value))}"]
      end)

    Enum.join([tag | encoded_attrs], "\t")
  end
end
