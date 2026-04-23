# Bindings and Interactions

`UnifiedUi` models interactivity through canonical bindings and interactions.
The goal is to describe event meaning once, without coupling authored modules
to a specific runtime’s callback names or payload format.

## Signals Section

Signals live under:

```elixir
signals do
  namespace(:workspace)
  default_target(:session)
end
```

The section-level options are:

- `namespace`
- `default_target`
- `mode`

`mode` is canonical by default.

## Data Bindings

Use `data_binding` to describe authored state references:

```elixir
data_binding do
  id(:filters)
  path([:filters])
  scope([:screen])
  default(%{query: "", severity: :all})
end
```

Supported binding fields include:

- `id`
- `path`
- `scope`
- `default`
- `format`
- `source`
- `collection?`
- `depends_on`
- `derived`
- `summary`
- `metadata`

Widgets and forms then refer to those bindings by path or by id:

```elixir
form_builder :filters_form do
  binding_refs([:filters])
  interaction_refs([:filters_change, :filters_submit])
end

field :query_field do
  field_name(:query)
  value_path([:filters, :query])
end
```

## Interactions

Use `interaction` to describe canonical event meaning:

```elixir
interaction do
  id(:filters_submit)
  family(:submit)
  intent(:apply_filters)
  source_context(element_id: :filters_form, scope: :screen)
  target_intent(binding: :filters, action: :apply)
  payload_mapping(filters: binding_ref(:filters), action: :apply)
  binding_refs([:filters])
end
```

Supported interaction fields include:

- `id`
- `family`
- `intent`
- `source_context`
- `target_intent`
- `payload_mapping`
- `binding_refs`
- `summary`
- `metadata`

## Standard Interaction Families

The canonical interaction families currently supported are:

- `:click`
- `:change`
- `:submit`
- `:open`
- `:close`
- `:focus`
- `:selection`
- `:navigation`
- `:command`

## Common Patterns

### Form Change and Submit

```elixir
interaction do
  id(:filters_change)
  family(:change)
  intent(:update_filters)
  source_context(element_id: :filters_form, scope: :screen)
  target_intent(binding: :filters, entity: :dashboard)
  payload_mapping(filters: binding_ref(:filters), phase: :draft)
end
```

### Navigation

```elixir
interaction do
  id(:navigate_activity)
  family(:navigation)
  intent(:navigate_dashboard)
  source_context(element_id: :dashboard_tabs)
  target_intent(binding: :active_tab, route: :activity)
  payload_mapping(tab: binding_ref(:active_tab), destination: :activity)
end
```

### Overlay Open

```elixir
interaction do
  id(:open_settings)
  family(:open)
  intent(:open_settings)
  source_context(element_id: :open_settings_button)
  target_intent(overlay: :settings_dialog)
  payload_mapping(source: :button)
end
```

## Canonical, Not Renderer-Local

Authored interactions should describe meaning, not runtime mechanics.

Good:

- `family(:submit)`
- `target_intent(binding: :filters, action: :apply)`
- `payload_mapping(filters: binding_ref(:filters))`

Not part of the `UnifiedUi` DSL surface:

- `phx-click`
- `phx-submit`
- runtime-local event structs
- runtime-local payload envelope keys

## Review and Inspection

Inspect compiled signal output from `packages/unified-ui`:

```bash
mix unified_ui.inspect --example themed_signal_workspace
mix unified_ui.export --example themed_signal_workspace --format signals
```

Those workflows are the fastest way to confirm your authored bindings and
interactions remain canonical before handing the screen to a runtime package.
