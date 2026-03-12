defmodule LiveUi.Architecture.GoldenParityTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]

  alias LiveUi.Descriptor
  alias LiveUi.Runtime
  alias LiveUi.TestSupport.CounterScreen
  alias LiveUi.TestSupport.RawIur
  alias LiveUi.TestSupport.UnifiedUiCounterScreen
  alias LiveUi.WidgetRegistry

  @golden_dir Path.expand("../../fixtures/golden", __DIR__)

  test "screen sources and canonical iur inputs emit the same descriptor tree" do
    source_descriptor = source_descriptor(4, "golden")
    iur_descriptor = iur_descriptor(4, "golden")

    expected =
      Path.join(@golden_dir, "counter_descriptor.json")
      |> File.read!()
      |> Jason.decode!()

    assert canonical_term(source_descriptor) == canonical_term(iur_descriptor)
    assert canonical_term(source_descriptor) == expected
    assert canonical_term(iur_descriptor) == expected
  end

  test "screen sources and canonical iur inputs emit the same rendered html" do
    source_rendered = source_descriptor(4, "golden") |> render_descriptor() |> canonical_html()
    iur_rendered = iur_descriptor(4, "golden") |> render_descriptor() |> canonical_html()
    expected = File.read!(Path.join(@golden_dir, "counter_rendered.html")) |> canonical_html()

    assert source_rendered == iur_rendered
    assert source_rendered == expected
  end

  test "real unified_ui dsl screens and their emitted canonical iur share one descriptor pipeline" do
    source_descriptor = unified_ui_source_descriptor()
    iur_descriptor = unified_ui_iur_descriptor()

    expected =
      Path.join(@golden_dir, "unified_ui_counter_descriptor.json")
      |> File.read!()
      |> Jason.decode!()

    assert canonical_term(source_descriptor) == canonical_term(iur_descriptor)
    assert canonical_term(source_descriptor) == expected
    assert canonical_term(iur_descriptor) == expected
  end

  test "real unified_ui dsl screens and their emitted canonical iur share one rendered html contract" do
    source_rendered = unified_ui_source_descriptor() |> render_descriptor() |> canonical_html()
    iur_rendered = unified_ui_iur_descriptor() |> render_descriptor() |> canonical_html()

    expected =
      File.read!(Path.join(@golden_dir, "unified_ui_counter_rendered.html"))
      |> canonical_html()

    assert source_rendered == iur_rendered
    assert source_rendered == expected
  end

  defp source_descriptor(count, mount_token) do
    assert {:ok, model} =
             Runtime.init(
               source: CounterScreen,
               source_opts: [count: count, mount_token: mount_token],
               runtime_context: %{}
             )

    model.descriptor_tree
  end

  defp iur_descriptor(count, mount_token) do
    assert {:ok, model} =
             Runtime.init(
               iur: RawIur.counter_tree(count, mount_token: mount_token),
               runtime_context: %{}
             )

    model.descriptor_tree
  end

  defp render_descriptor(descriptor) do
    render_component(&WidgetRegistry.render/1, descriptor: descriptor_to_map(descriptor))
    |> rendered_to_string()
  end

  defp canonical_html(rendered) do
    rendered
    |> String.replace(~r/\s+/, " ")
    |> String.replace("> <", "><")
    |> String.trim()
  end

  defp descriptor_to_map(%Descriptor{} = descriptor) do
    %{
      "id" => descriptor.id,
      "kind" => descriptor.kind,
      "props" => canonical_term(descriptor.props),
      "children" => Enum.map(descriptor.children, &descriptor_to_map/1),
      "signal_bindings" => canonical_term(descriptor.signal_bindings)
    }
  end

  defp descriptor_to_map(%{} = descriptor) do
    descriptor
    |> canonical_term()
    |> Map.new()
  end

  defp canonical_term(%Descriptor{} = descriptor), do: descriptor_to_map(descriptor)

  defp canonical_term(%{} = map) do
    map
    |> Enum.map(fn {key, value} -> {to_string(key), canonical_term(value)} end)
    |> Enum.sort_by(fn {key, _value} -> key end)
    |> Enum.into(%{})
  end

  defp canonical_term(list) when is_list(list), do: Enum.map(list, &canonical_term/1)
  defp canonical_term(other), do: other

  defp unified_ui_source_descriptor do
    assert {:ok, model} =
             Runtime.init(
               source: UnifiedUiCounterScreen,
               source_opts: [],
               runtime_context: %{}
             )

    model.descriptor_tree
  end

  defp unified_ui_iur_descriptor do
    state = UnifiedUiCounterScreen.init([])

    assert {:ok, model} =
             Runtime.init(
               iur: UnifiedUiCounterScreen.view(state),
               runtime_context: %{}
             )

    model.descriptor_tree
  end
end
