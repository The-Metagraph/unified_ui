defmodule UnifiedUi.Dsl.Placement do
  @moduledoc """
  Baseline section-boundary and placement rules for authored `UnifiedUi` modules.
  """

  @section_boundaries %{
    identity: [:id, :title, :description, :authored_ref, :annotations, :tags],
    composition: [:root, :mode, :summary, :default_slot],
    themes: [:default_theme, :inherit?, :summary],
    signals: [:namespace, :default_target, :mode]
  }

  @placement_rules [
    %{
      id: :required_identity_and_composition_sections,
      description:
        "Authored modules must declare identity and composition sections before higher-level constructs are added."
    },
    %{
      id: :root_identifier_must_differ_from_module_identifier,
      description:
        "The composition root identifier must not duplicate the module identity identifier."
    },
    %{
      id: :default_slot_requires_fragment_mode,
      description:
        "A default slot may only be declared when the authored composition mode is :fragment."
    },
    %{
      id: :field_requires_one_input_child,
      description:
        "Field composition nodes must contain exactly one child and that child must be an input control."
    },
    %{
      id: :leaf_nodes_cannot_have_children,
      description:
        "Leaf widget and navigation nodes may not declare nested children in the authored Phase 2 surface."
    }
  ]

  @leaf_kinds [
    :text,
    :label,
    :icon,
    :image,
    :button,
    :link,
    :separator,
    :spacer,
    :text_input,
    :toggle,
    :select,
    :menu,
    :tabs,
    :command_palette
  ]

  @layout_kinds [:box, :row, :column, :grid, :stack]
  @container_kinds [:content, :form_builder, :field_group]

  @spec section_boundaries() :: %{atom() => [atom()]}
  def section_boundaries do
    @section_boundaries
  end

  @spec placement_rules() :: [map()]
  def placement_rules do
    @placement_rules
  end

  @spec leaf_kinds() :: [atom()]
  def leaf_kinds do
    @leaf_kinds
  end

  @spec layout_kinds() :: [atom()]
  def layout_kinds do
    @layout_kinds
  end

  @spec container_kinds() :: [atom()]
  def container_kinds do
    @container_kinds
  end

  @spec valid_default_slot?(atom() | nil, atom() | nil) :: boolean()
  def valid_default_slot?(:fragment, default_slot), do: is_atom(default_slot)
  def valid_default_slot?(_mode, nil), do: true
  def valid_default_slot?(_mode, _default_slot), do: false
end
