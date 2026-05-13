# Runtime Parity Matrix

Back to index: [README](./README.md)

This review-facing mirror summarizes
[`runtime-parity-matrix.json`](./runtime-parity-matrix.json). The JSON file is
the executable source used by DesktopUi and TerminalUi parity tests.

| Widget | Desktop Support | Terminal Support | Terminal Fallback |
| --- | --- | --- | --- |
| `disclosure` | direct | fallback | `inline_disclosure` |
| `kicker` | direct | direct | none |
| `avatar` | direct | fallback | `initials_text` |
| `presence_dot` | direct | fallback | `status_text` |
| `segmented_button_group` | direct | fallback | `inline_menu_selection` |
| `list_item_multi_column` | direct | fallback | `linearized_row` |
| `artifact_row` | direct | fallback | `linearized_row` |
| `sticky_header` | direct | fallback | `inline_header` |
| `pipeline_stepper_horizontal` | direct | fallback | `ascii_progress` |
| `segmented_progress_bar` | direct | fallback | `ascii_progress` |
| `workflow_stage_list_vertical` | direct | fallback | `linearized_list` |
| `meter_thin` | direct | fallback | `ascii_progress` |
| `slide_over_panel` | direct | fallback | `inline_overlay` |
| `event_callout` | direct | fallback | `inline_feedback` |
| `redline_inline` | direct | fallback | `inline_diff` |
| `code_block_syntax_highlighted` | direct | fallback | `plain_code_block` |
| `chat_composer` | direct | fallback | `inline_text_prompt` |
| `host_form_shell` | direct | fallback | `linearized_form` |
| `repeated_collection` | direct | fallback | `linearized_collection` |

## Minimum Row-Scope Parity

Both non-web runtimes must preserve stable row keys, key sources, row indexes,
item identity, row-scope payload mappings, empty states, and explicit
diagnostics for missing keys, duplicate keys, and unresolved row-scope bindings.
