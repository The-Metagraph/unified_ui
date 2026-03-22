defmodule TerminalUi.StyleThemeTest do
  use ExUnit.Case, async: true

  alias TerminalUi.Runtime.StyleResolver
  alias UnifiedIUR.Element

  test "native style primitives and theme catalogs stay directly usable" do
    primitives = TerminalUi.Style.primitives()
    theme = TerminalUi.Theme.default_theme()

    assert :accent in primitives.colors
    assert :bold in primitives.text_attributes
    assert :primary_action in primitives.semantic_roles
    assert :accented in primitives.variants
    assert :unicode in primitives.glyph_sets
    assert :theme_tokens in TerminalUi.Style.portable_keys()
    assert :theme_tokens in TerminalUi.Style.widget_style_hooks()

    assert theme.id == :terminal_default
    assert :high_contrast in TerminalUi.Theme.catalog_ids()
    assert theme.component_defaults.button.semantic_role == :primary_action

    assert TerminalUi.Theme.continuity_rules().inheritance_order == [
             :theme_defaults,
             :semantic_role,
             :variant_defaults,
             :local_styles
           ]
  end

  test "style resolution merges theme defaults, variants, tokens, and local overrides" do
    widget =
      TerminalUi.Widgets.button("save", "Save",
        theme: :high_contrast,
        variant: :accented,
        semantic_role: :primary_action,
        fg: :success,
        attrs: [:bold],
        theme_tokens: %{surface: [:surface, :panel]},
        state_variants: %{focused: %{attrs: [:underline]}},
        focused: true
      )

    resolution = StyleResolver.resolve(widget)

    assert resolution.theme == :high_contrast
    assert resolution.resolved.theme == :high_contrast
    assert resolution.resolved.variant == :accented
    assert resolution.resolved.semantic_role == :primary_action
    assert resolution.resolved.fg == :success
    assert :bold in resolution.resolved.attrs
    assert :underline in resolution.resolved.attrs
    assert resolution.resolved.border == :double
    assert resolution.active_states == [:focused]
  end

  test "canonical widgets realize through the same shared style model" do
    element =
      Element.new(:widget, :button,
        id: "save",
        attributes: %{
          text: "Save",
          theme: :high_contrast,
          style: %{
            variant: :accented,
            semantic_role: :primary_action,
            fg: :success,
            theme_tokens: %{surface: [:surface, :panel]}
          }
        }
      )

    assert {:ok, widget} = TerminalUi.Renderer.Mapper.map(element)

    resolution = StyleResolver.resolve(widget)

    assert widget.styles.theme == :high_contrast
    assert widget.styles.variant == :accented
    assert widget.styles.semantic_role == :primary_action
    assert resolution.theme == :high_contrast
    assert resolution.resolved.fg == :success
    assert resolution.resolved.border == :double
  end
end
