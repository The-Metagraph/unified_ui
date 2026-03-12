# LiveUi Theme System

The theme system subject defines how live_ui maps `UnifiedIUR` style intent into a library-owned visual language.

It owns default design tokens, semantic classes, CSS variable contracts, and host-overridable theme surfaces for the independent widget library, and those rules should apply consistently to both direct widget use and IUR-driven rendering.

```spec-meta
{
  "id": "module.live_ui_theme_system",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Style.Compiler", "LiveUi.Style.Theme"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_iur_interpreter"},
    {"kind": "depends_on", "target": "module.live_ui_widget_system"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"},
    {"kind": "relates_to", "target": "module.live_ui_host_integration"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "rendering",
  "change_rules": [
    {
      "id": "theme_system_changes_require_widget_and_host_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_widget_system", "module.live_ui_host_integration"]},
        {"verification_kinds": ["doc", "test_file"]}
      ],
      "severity": "error"
    }
  ],
  "approval": {
    "required": true,
    "roles": ["maintainer"]
  },
  "gates": [
    {
      "id": "local_spec_check",
      "kind": "mix_task",
      "target": "mix live_ui.spec.check",
      "mode": "required"
    }
  ]
}
```

## Requirements

```spec-requirements
[
  {
    "id": "live_ui_theme.maps_iur_style_to_tokens",
    "statement": "When a render-tree node carries UnifiedIUR style metadata, the theme system shall map that metadata into semantic classes, variants, or CSS variables owned by live_ui.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_theme.provides_default_design_tokens",
    "statement": "When the widget library renders without host overrides, the theme system shall provide a default token set covering spacing, typography, color, elevation, and motion.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_theme.supports_host_overrides",
    "statement": "When a host application needs a branded presentation, the theme system shall expose stable override surfaces that do not require changing UnifiedIUR payload shapes.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_theme.supports_direct_widget_usage",
    "statement": "When a host renders live_ui widgets directly without UnifiedIUR input, the theme system shall apply the same design-token and variant rules used by IUR-driven rendering.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_theme.keeps_visual_semantics_library_owned",
    "statement": "While upstream producers may express style intent in UnifiedIUR, the theme system shall keep the concrete visual semantics owned by live_ui rather than inheriting upstream renderer contracts.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_theme.default_token_application",
    "given": ["a render tree containing widgets with style metadata"],
    "when": ["the tree is rendered without host overrides"],
    "then": ["default live_ui theme tokens are applied consistently across the widget library"],
    "covers": ["live_ui_theme.maps_iur_style_to_tokens", "live_ui_theme.provides_default_design_tokens", "live_ui_theme.keeps_visual_semantics_library_owned"]
  },
  {
    "id": "live_ui_theme.direct_widget_token_application",
    "given": ["a host application rendering live_ui widgets directly"],
    "when": ["the widgets are rendered without UnifiedIUR input"],
    "then": ["the same theme tokens and variants used by IUR-driven rendering are applied"],
    "covers": ["live_ui_theme.supports_direct_widget_usage", "live_ui_theme.provides_default_design_tokens"]
  },
  {
    "id": "live_ui_theme.host_override_application",
    "given": ["a host application providing theme overrides"],
    "when": ["live_ui widgets are rendered inside the host"],
    "then": ["the host can override the library theme without mutating the underlying UnifiedIUR payloads"],
    "covers": ["live_ui_theme.supports_host_overrides", "live_ui_theme.keeps_visual_semantics_library_owned"]
  }
]
```

## Verification

```spec-verification
[
  {
    "kind": "doc",
    "target": "docs/architecture.md",
    "covers": [
      "live_ui_theme.maps_iur_style_to_tokens",
      "live_ui_theme.provides_default_design_tokens",
      "live_ui_theme.supports_host_overrides",
      "live_ui_theme.supports_direct_widget_usage",
      "live_ui_theme.keeps_visual_semantics_library_owned"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/widget_rendering_test.exs",
    "covers": [
      "live_ui_theme.maps_iur_style_to_tokens",
      "live_ui_theme.provides_default_design_tokens",
      "live_ui_theme.supports_direct_widget_usage",
      "live_ui_theme.keeps_visual_semantics_library_owned"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/assets/hooks_test.exs",
    "covers": ["live_ui_theme.supports_host_overrides"]
  }
]
```
