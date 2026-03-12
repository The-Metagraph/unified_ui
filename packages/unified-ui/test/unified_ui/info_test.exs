defmodule UnifiedUi.InfoTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Info
  alias UnifiedUi.Dsl.CompileIndex
  alias UnifiedUi.Dsl.Style, as: DslStyle
  @widget_prefix "Elixir.UnifiedIUR.Widgets."
  @layout_prefix "Elixir.UnifiedIUR.Layouts."

  test "UnifiedUi.Info module is available" do
    assert Code.ensure_loaded?(UnifiedUi.Info)
  end

  test "widgets/1 and layouts/1 return flattened UI entities" do
    module =
      compile_fixture("""
      vbox do
        id :root
        text "Hello", id: :greeting

        hbox do
          id :actions
          button "Save", id: :save
          button "Cancel", id: :cancel
        end
      end
      """)

    widgets = Info.widgets(module)
    layouts = Info.layouts(module)

    assert Enum.all?(widgets, &entity_prefix?(&1, @widget_prefix))
    assert Enum.all?(layouts, &entity_prefix?(&1, @layout_prefix))

    assert widgets |> Enum.map(& &1.id) |> Enum.sort() == [:cancel, :greeting, :save]
    assert layouts |> Enum.map(& &1.id) |> Enum.sort() == [:actions, :root]
  end

  test "styles/1 returns style entities from styles section" do
    module =
      compile_fixture("""
      vbox do
        id :root
        text "Styled", id: :styled_text
      end

      styles do
        style :primary do
          attributes [fg: :blue, attrs: [:bold]]
        end
      end
      """)

    styles = Info.styles(module)

    assert Enum.any?(styles, &match?(%DslStyle{name: :primary}, &1))
  end

  test "signals/1 returns standard signals" do
    module =
      compile_fixture("""
      vbox do
        id :root
        button "Click", id: :click_me, on_click: :clicked
      end
      """)

    assert Info.signals(module) == UnifiedUi.Dsl.standard_signals()
  end

  test "widgets/1 and layouts/1 support DSL state maps" do
    module =
      compile_fixture("""
      vbox do
        id :root
        text "Hello", id: :greeting
      end
      """)

    runtime_state = CompileIndex.runtime_view_state(module)

    assert [%UnifiedIUR.Widgets.Text{id: :greeting}] = Info.widgets(runtime_state)
    assert [%UnifiedIUR.Layouts.VBox{id: :root}] = Info.layouts(runtime_state)
  end

  defp compile_fixture(body) do
    module =
      Module.concat([
        UnifiedUi,
        InfoFixture,
        :"M#{System.unique_integer([:positive])}"
      ])

    source = """
    defmodule #{inspect(module)} do
      @behaviour UnifiedUi.ElmArchitecture
      use UnifiedUi.Dsl

      #{body}
    end
    """

    Code.compile_string(source)
    module
  end

  defp entity_prefix?(%{__struct__: module}, prefix) when is_atom(module) do
    module
    |> Atom.to_string()
    |> String.starts_with?(prefix)
  end

  defp entity_prefix?(_entity, _prefix), do: false
end
