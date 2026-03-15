defmodule UnifiedUi.Compiler.Result do
  @moduledoc """
  Canonical compiler result for one authored `UnifiedUi` module.
  """

  alias UnifiedIUR.{Binding, Element, Interaction, Theme}

  @type t :: %__MODULE__{
          module: module(),
          identity: map(),
          composition: map(),
          iur: Element.t(),
          themes: [Theme.t()],
          default_theme: atom() | String.t() | nil,
          bindings: [Binding.t()],
          interactions: [Interaction.t()],
          trace: map()
        }

  defstruct module: nil,
            identity: %{},
            composition: %{},
            iur: nil,
            themes: [],
            default_theme: nil,
            bindings: [],
            interactions: [],
            trace: %{}

  @spec summary(t()) :: map()
  def summary(%__MODULE__{} = result) do
    %{
      module: result.module,
      identity_id: result.identity.id,
      authored_ref: result.identity.authored_ref,
      root_id: result.composition.root,
      mode: result.composition.mode,
      default_theme: result.default_theme,
      top_level_children: Enum.map(result.iur.children, &child_summary/1),
      theme_ids: Enum.map(result.themes, & &1.id),
      binding_names: Enum.map(result.bindings, & &1.name),
      interaction_families: Enum.map(result.interactions, & &1.family),
      interaction_intents: Enum.map(result.interactions, & &1.intent),
      trace: trace_summary(result.trace)
    }
  end

  defp child_summary(child) do
    case child.element do
      nil ->
        %{slot: child.slot, id: nil, type: nil, kind: nil}

      element ->
        %{slot: child.slot, id: element.id, type: element.type, kind: element.kind}
    end
  end

  defp trace_summary(trace) do
    %{
      authored_ids: Map.get(trace, :authored_ids, []),
      binding_ids: trace |> Map.get(:binding_by_id, %{}) |> Map.keys() |> Enum.sort(),
      interaction_ids: trace |> Map.get(:interaction_by_id, %{}) |> Map.keys() |> Enum.sort(),
      theme_ids: trace |> Map.get(:theme_by_id, %{}) |> Map.keys() |> Enum.sort()
    }
  end
end
