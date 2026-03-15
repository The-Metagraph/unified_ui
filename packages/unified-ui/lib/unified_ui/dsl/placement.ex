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
    }
  ]

  @spec section_boundaries() :: %{atom() => [atom()]}
  def section_boundaries do
    @section_boundaries
  end

  @spec placement_rules() :: [map()]
  def placement_rules do
    @placement_rules
  end

  @spec valid_default_slot?(atom() | nil, atom() | nil) :: boolean()
  def valid_default_slot?(:fragment, default_slot), do: is_atom(default_slot)
  def valid_default_slot?(_mode, nil), do: true
  def valid_default_slot?(_mode, _default_slot), do: false
end
