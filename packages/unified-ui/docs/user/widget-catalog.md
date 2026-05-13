# UnifiedUi Widget Catalog

This guide summarizes the authored widget and construct families currently
available in `UnifiedUi`.

Every widget shares a common baseline schema:

- `id`: stable authored node id
- `description`, `authored_ref`, `annotations`, `tags`
- `variant`, `tone`
- `theme_ref`, `style_refs`, `style`
- `interaction_refs`, `binding_refs`
- `accessibility_label`, `accessibility_description`
- `disabled?`

## Foundational Widgets

| Widget | Purpose | Key authored fields |
| --- | --- | --- |
| `text` | Display text content | `value`, `role` |
| `label` | Label another control | `value`, `target` |
| `icon` | Icon glyph | `name`, `set`, `fallback_text` |
| `image` | Image/media content | `source`, `alt_text`, `media_type`, `fit` |
| `badge` | Small status label | `value`, `name`, `set`, `presentation` |
| `button` | Action trigger | `label`, `action_intent`, `emphasis` |
| `link` | Navigation link | `label`, `target`, `external?`, `target_kind`, `navigation_target` |
| `separator` | Visual divider | `orientation`, `decorative?` |
| `spacer` | Intentional empty space | `size`, `grow` |
| `content` | Group foundational children | `role`, `presentation`, `summary` |
| `hero` | Large lead section | `eyebrow`, `title`, `message`, `align`, `summary` |

Example:

```elixir
box :intro do
  text :headline do
    value("UnifiedUi")
  end

  badge :status_badge do
    value("Preview")
    presentation(:pill)
  end

  button :start_button do
    label("Get started")
    action_intent(:start)
  end
end
```

## Input Widgets

| Widget | Purpose | Key authored fields |
| --- | --- | --- |
| `text_input` | Freeform text | `placeholder`, `value_path`, `default_value`, `multiline?`, `input_mode` |
| `numeric_input` | Numeric entry | `placeholder`, `value_path`, `default_value`, `min`, `max`, `step` |
| `toggle` | Boolean switch | `label`, `value_path`, `default_value` |
| `checkbox` | Boolean checkbox | `label`, `value_path`, `default_value` |
| `radio_group` | Single choice from options | `label`, `options`, `value_path`, `default_value` |
| `select` | Select dropdown | `label`, `options`, `value_path`, `default_value`, `multiple?` |
| `pick_list` | Multi-select list | `label`, `options`, `value_path`, `default_value`, `multiple?` |
| `date_input` | Date input | `value_path`, `default_value`, `format`, `min`, `max` |
| `time_input` | Time input | `value_path`, `default_value`, `format`, `min`, `max`, `step` |
| `file_input` | File selection | `label`, `value_path`, `accept`, `multiple?`, `capture` |

Example:

```elixir
field :email do
  field_name(:email)
  label("Email")
  value_path([:profile, :email])

  text_input :email_input do
    placeholder("name@example.com")
    input_mode(:email)
  end
end
```

## Navigation and Form Workflow Widgets

| Widget | Purpose | Key authored fields |
| --- | --- | --- |
| `menu` | Menu of named items | `items`, `active_item`, `orientation` |
| `tabs` | Tabbed navigation | `items`, `active_item`, `orientation` |
| `command_palette` | Command chooser | `items`, `label`, `summary` |
| `form_builder` | Form root | `summary`, `submit_intent` |
| `field_group` | Group form fields | `legend`, `summary` |
| `field` | Named field container | `field_name`, `label`, `help`, `value_path`, `default_value` |
| `form_field` | Alternate field container | `field_name`, `label`, `help`, `value_path`, `default_value` |

Example:

```elixir
form_builder :profile_form do
  submit_intent(:save_profile)

  field_group :identity do
    legend("Identity")

    field :display_name do
      field_name(:display_name)
      label("Display name")

      text_input :display_name_input do
        placeholder("Display name")
      end
    end
  end

  tabs :profile_tabs do
    items(profile: "Profile", permissions: "Permissions")
    active_item(:profile)
  end
end
```

## Data, Feedback, and Operational Widgets

| Widget | Purpose | Key authored fields |
| --- | --- | --- |
| `list` | Ordered or unordered list | `items`, `ordered?`, `selection_mode`, `empty_state`, `summary` |
| `table` | Tabular data | `table_columns`, `table_rows`, `empty_state`, `summary` |
| `tree_view` | Hierarchical data | `tree_nodes`, `expanded?`, `empty_state`, `summary` |
| `stat` | Title/value metric | `title`, `value`, `message`, `summary` |
| `key_value` | Label/value pair | `label`, `value`, `description`, `summary` |
| `info_list` | Descriptive item list | `items`, `ordered?`, `empty_state`, `summary` |
| `markdown_viewer` | Render markdown source | `source`, `presentation`, `summary` |
| `log_viewer` | Log/event stream | `log_entries`, `show_timestamps?`, `wrap?`, `empty_state`, `summary` |
| `status` | Short status indicator | `value`, `severity`, `status`, `summary` |
| `progress` | Progress surface | `current`, `maximum`, `label`, `severity`, `status`, `indeterminate?`, `summary` |
| `gauge` | Gauge meter | `current`, `minimum`, `maximum`, `label`, `severity`, `status`, `summary` |
| `inline_feedback` | Inline message | `title`, `message`, `severity`, `status`, `summary` |
| `sparkline` | Small trend line | `points`, `summary` |
| `bar_chart` | Bar chart | `series`, `x_label`, `y_label`, `empty_state`, `summary` |
| `line_chart` | Line chart | `series`, `x_label`, `y_label`, `empty_state`, `summary` |
| `stream_widget` | Append-oriented event stream | `entries`, `ordering`, `severity_field`, `timestamp_field`, `summary` |
| `process_monitor` | Process list | `processes`, `sort_by`, `severity`, `summary` |
| `supervision_tree_viewer` | Supervision topology | `topology`, `expanded?`, `summary` |
| `cluster_dashboard` | Cluster health surface | `cluster_nodes`, `metrics`, `severity`, `summary` |

Example:

```elixir
column :operations_shell do
  table :deployments_table do
    table_columns(name: "Name", status: "Status")
    table_rows([
      [name: "API", status: "Healthy"],
      [name: "Web", status: "Degraded"]
    ])
  end

  gauge :cpu_gauge do
    current(72)
    maximum(100)
    severity(:warning)
  end
end
```

## Promoted Semantic and Workflow Widgets

These widgets came from AshUi-oriented proposals but are canonical only when
authored without Ash, Phoenix, or runtime callback names.

| Widget | Purpose | Key authored fields |
| --- | --- | --- |
| `disclosure` | Compact expand/collapse state | `label`, `open?`, `content_label` |
| `kicker` | Small contextual label | `value`, `icon`, `role` |
| `avatar` | Person or actor identity | `label`, `initials`, `avatar_source`, `status` |
| `presence_dot` | Availability marker | `status`, `label`, `pulse?` |
| `segmented_button_group` | Segment selection | `items`, `active_item`, `selection_mode`, `orientation` |
| `list_item_multi_column` | Row summary with portable columns | `columns`, `label`, `value`, `status` |
| `artifact_row` | Artifact-oriented row summary | `artifact`, `title`, `status`, `timestamp`, `action_intent` |
| `sticky_header` | Header with sticky state | `title`, `stuck?`, `elevation` |
| `pipeline_stepper_horizontal` | Pipeline progress stepper | `steps`, `active_item`, `status` |
| `segmented_progress_bar` | Segmented progress | `segments`, `current`, `maximum` |
| `workflow_stage_list_vertical` | Vertical workflow stage list | `stages`, `active_item`, `status` |
| `meter_thin` | Thin meter | `current`, `minimum`, `maximum`, `severity` |
| `slide_over_panel` | Portable side panel intent | `title`, `placement`, `visible?`, `modal?` |
| `event_callout` | Event message | `message`, `title`, `severity`, `timestamp` |
| `redline_inline` | Inline before/after text | `before_text`, `after_text`, `label` |
| `code_block_syntax_highlighted` | Code block with language metadata | `code`, `language`, `wrap?` |
| `chat_composer` | Message composer intent | `placeholder`, `submit_intent`, `actions`, `multiline?` |

Example:

```elixir
artifact_row :release_artifact do
  title("release.tar")
  artifact(%{id: "release.tar", kind: :archive})
  status(:ready)
  action_intent(:open_artifact)
end

chat_composer :review_note do
  placeholder("Add a review note")
  submit_intent(:send_review)
  actions(send: "Send")
end
```

## Host-Owned Form Shells

`host_form_shell` is the portable replacement for proposal names like
`phoenix_form`. It records host lifecycle ownership and canonical submit or
validation intent without embedding Phoenix form structs, Ash changesets, or
AshPhoenix behavior.

```elixir
host_form_shell :profile_shell do
  owner(:host)
  lifecycle(:host_owned)
  submit_intent(:save_profile)
  validation_summary("Host validates profile changes")
  action_placement(:footer)
end
```

## Repeated Collections

`repeated_collection` binds a portable list-oriented source to one child
template per row. The source can be a canonical binding reference or portable
data descriptor, but it must not be an Ash relationship traversal or
renderer-local callback.

Row templates use `row_value/2`, `row_index/1`, and `row_key/2` descriptors so
runtime renderers can hydrate row content without changing canonical meaning.

```elixir
repeated_collection :artifact_rows do
  collection_source(binding_ref(:artifacts))
  item_alias(:artifact)
  index_alias(:row)
  key_path([:id])
  empty_state("No artifacts")

  row_template :artifact_template do
    template_children([
      %{
        kind: :artifact_row,
        id: :artifact_record,
        title: "Artifact",
        artifact: row_value([:record], alias: :artifact),
        status: :ready
      },
      %{
        kind: :list_item_multi_column,
        id: :artifact_summary,
        columns: row_value([:columns], alias: :artifact),
        value: row_index(alias: :row)
      }
    ])
  end
end
```

## When to Use the Package Examples

If you want real end-to-end authored references instead of isolated snippets,
inspect:

- `UnifiedUi.Examples.FoundationalScreen`
- `UnifiedUi.Examples.ProfileForm`
- `UnifiedUi.Examples.OperationsDashboard`
- `UnifiedUi.Examples.ThemedSignalWorkspace`
