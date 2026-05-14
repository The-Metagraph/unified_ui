# UnifiedIUR Interoperability

This subject defines the interoperability expectations that make `unified_iur`
usable as the canonical exchange boundary for multiple runtime libraries.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [UnifiedIUR Package](./package.spec.md)
- [UnifiedIUR Core](./core.spec.md)
- [UnifiedIUR Constructs](./constructs.spec.md)

```spec-meta
id: unified_iur.interoperability
kind: integration
status: active
summary: Target interoperability contract for canonical portability, deterministic structure, and runtime-library consumption of `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/interoperability.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.interoperability.runtime_library_consumption
  statement: Canonical `unified_iur` structures shall be organized so `elm_ui`, `live_ui`, and `desktop_ui` can consume them as renderer entry input without requiring authored DSL modules.
  priority: must
  stability: stable

- id: unified_iur.interoperability.deterministic_shape
  statement: Equivalent authored input shall yield deterministic canonical IUR shape so diffs, tests, reviews, and runtime-library mappings remain stable.
  priority: must
  stability: stable

- id: unified_iur.interoperability.portable_data_model
  statement: The canonical IUR model shall remain portable across runtime boundaries and suitable for transformation into the structures each runtime library needs to realize its own native widgets, layers, styling, and signals.
  priority: must
  stability: stable

- id: unified_iur.interoperability.no_runtime_local_escape_hatches
  statement: The package shall not rely on `elm_ui`, `live_ui`, or `desktop_ui` native widget structs, renderer-local style objects, or runtime-local signal envelopes as part of the canonical IUR model.
  priority: must
  stability: stable

- id: unified_iur.interoperability.extension_strategy
  statement: The package shall support forward-compatible extension of canonical constructs so new widgets, layouts, layer constructs, styles, and interactions can be introduced without destabilizing existing runtime-library consumers.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.interoperability.one_iur_many_runtimes
  covers:
    - unified_iur.interoperability.runtime_library_consumption
    - unified_iur.interoperability.deterministic_shape
    - unified_iur.interoperability.portable_data_model
    - unified_iur.interoperability.no_runtime_local_escape_hatches
    - unified_iur.interoperability.extension_strategy
  given:
    - The same canonical screen is rendered by `elm_ui`, `live_ui`, and `desktop_ui`
  when:
    - Each runtime library loads canonical IUR
  then:
    - Each library can realize the same authored meaning through its own native surface without requiring a renderer-specific canonical representation
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/interoperability.spec.md
  covers:
    - unified_iur.interoperability.runtime_library_consumption
    - unified_iur.interoperability.deterministic_shape
    - unified_iur.interoperability.portable_data_model
    - unified_iur.interoperability.no_runtime_local_escape_hatches
    - unified_iur.interoperability.extension_strategy
    - unified_iur.interoperability.one_iur_many_runtimes
```
