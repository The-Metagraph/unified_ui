defmodule UnifiedUi.GuidesDashboardTutorialTest do
  use ExUnit.Case, async: false

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Terminal
  alias UnifiedUi.Adapters.Terminal.Events

  @guide_path "guides/dashboard-tutorial.md"
  @elixir_fence ~r/```elixir[^\n]*\n(.*?)\n```/ms

  test "dashboard tutorial can be followed end-to-end" do
    module = compile_tutorial_module()

    state = module.init([])

    assert state == %{
             cpu: 42,
             memory: 68,
             trend: [20, 35, 42, 55, 48],
             mode: :overview
           }

    iur = module.view(state)
    assert %Layouts.VBox{id: :dashboard} = iur
    assert includes_widget_id?(iur, Widgets.Gauge, :cpu)
    assert includes_widget_id?(iur, Widgets.Gauge, :memory)
    assert includes_widget_id?(iur, Widgets.LineChart, :trend)

    assert {:ok, render_state} = Terminal.render(iur)
    assert {:ok, _root} = State.get_root(render_state)

    assert {:ok, refresh_signal} =
             Events.to_signal(:click, %{widget_id: :refresh_button, action: :refresh})

    refreshed_state = module.update(state, refresh_signal)

    assert refreshed_state == %{
             cpu: 50,
             memory: 61,
             trend: [35, 42, 55, 48, 50],
             mode: :overview
           }

    refreshed_iur = module.view(refreshed_state)
    assert {:ok, refreshed_render_state} = Terminal.update(refreshed_iur, render_state)

    assert {:ok, toggle_mode_signal} =
             Events.to_signal(:click, %{widget_id: :toggle_mode_button, action: :toggle_mode})

    toggled_state = module.update(refreshed_state, toggle_mode_signal)
    assert toggled_state.mode == :detailed

    toggled_iur = module.view(toggled_state)
    assert {:ok, final_render_state} = Terminal.update(toggled_iur, refreshed_render_state)
    assert {:ok, _root} = State.get_root(final_render_state)
  end

  defp compile_tutorial_module do
    [module_block | _] =
      @guide_path
      |> File.read!()
      |> extract_elixir_blocks()

    fixture_module =
      Module.concat([
        UnifiedUi,
        DashboardTutorialFixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source =
      String.replace(
        module_block,
        ~r/defmodule\s+MyApp\.DashboardScreen/,
        "defmodule #{inspect(fixture_module)}",
        global: false
      )

    Code.compile_string(source)
    fixture_module
  end

  defp extract_elixir_blocks(markdown) do
    @elixir_fence
    |> Regex.scan(markdown, capture: :all_but_first)
    |> Enum.map(&hd/1)
    |> Enum.map(&String.trim/1)
  end

  defp includes_widget_id?(%Layouts.VBox{children: children}, widget_module, id) do
    Enum.any?(children, &includes_widget_id?(&1, widget_module, id))
  end

  defp includes_widget_id?(%Layouts.HBox{children: children}, widget_module, id) do
    Enum.any?(children, &includes_widget_id?(&1, widget_module, id))
  end

  defp includes_widget_id?(%widget_module{id: id}, widget_module, id), do: true
  defp includes_widget_id?(_, _widget_module, _id), do: false
end
