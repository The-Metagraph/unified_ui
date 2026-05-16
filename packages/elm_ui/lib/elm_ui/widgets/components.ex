defmodule ElmUi.Widgets.Components do
  @moduledoc """
  Native `elm_ui` component models for the canonical widget-component catalog.

  These constructors are directly usable by ElmUi callers while preserving the
  same semantic attribute shape that canonical IUR renderers consume.
  """

  alias ElmUi.Widgets.Builder

  @content_identity_kinds [
    :inline_rich_text_heading,
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot
  ]

  @form_control_kinds [
    :segmented_button_group,
    :runtime_form_shell,
    :chat_composer,
    :mode_nav
  ]

  @row_artifact_kinds [
    :list_item_multi_column,
    :artifact_row
  ]

  @workflow_progress_kinds [
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :unread_badge
  ]

  @layer_callout_kinds [
    :sticky_frosted_header,
    :slide_over_panel,
    :event_callout,
    :top_strip,
    :sidebar_shell,
    :sidebar_section,
    :sidebar_item,
    :command_palette
  ]

  @redline_code_kinds [
    :redline_inline,
    :code_block_syntax_highlighted
  ]

  @composition_behavior_kinds [
    :list_repeat
  ]

  @component_families %{
    inline_rich_text_heading: :content_identity,
    disclosure: :content_identity,
    kicker: :content_identity,
    avatar: :content_identity,
    presence_dot: :content_identity,
    segmented_button_group: :form_control,
    runtime_form_shell: :form_control,
    chat_composer: :form_control,
    list_item_multi_column: :row_artifact,
    artifact_row: :row_artifact,
    pipeline_stepper_horizontal: :workflow_progress,
    segmented_progress_bar: :workflow_progress,
    workflow_stage_list_vertical: :workflow_progress,
    meter_thin: :workflow_progress,
    sticky_frosted_header: :layer_callout,
    slide_over_panel: :layer_callout,
    event_callout: :layer_callout,
    top_strip: :layer_callout,
    sidebar_shell: :layer_callout,
    sidebar_section: :layer_callout,
    sidebar_item: :layer_callout,
    command_palette: :layer_callout,
    mode_nav: :form_control,
    unread_badge: :workflow_progress,
    redline_inline: :redline_code,
    code_block_syntax_highlighted: :redline_code,
    list_repeat: :composition_behavior
  }

  @kinds @content_identity_kinds ++
           @form_control_kinds ++
           @row_artifact_kinds ++
           @workflow_progress_kinds ++
           @layer_callout_kinds ++
           @redline_code_kinds ++
           @composition_behavior_kinds

  @spec kinds() :: [atom()]
  def kinds, do: @kinds

  @spec family_for_kind(atom() | String.t()) :: atom() | nil
  def family_for_kind(kind) when is_binary(kind),
    do: kind |> String.to_atom() |> family_for_kind()

  def family_for_kind(kind), do: Map.get(@component_families, kind)

  @spec content_identity_kinds() :: [atom()]
  def content_identity_kinds, do: @content_identity_kinds

  @spec form_control_kinds() :: [atom()]
  def form_control_kinds, do: @form_control_kinds

  @spec row_artifact_kinds() :: [atom()]
  def row_artifact_kinds, do: @row_artifact_kinds

  @spec workflow_progress_kinds() :: [atom()]
  def workflow_progress_kinds, do: @workflow_progress_kinds

  @spec layer_callout_kinds() :: [atom()]
  def layer_callout_kinds, do: @layer_callout_kinds

  @spec redline_code_kinds() :: [atom()]
  def redline_code_kinds, do: @redline_code_kinds

  @spec composition_behavior_kinds() :: [atom()]
  def composition_behavior_kinds, do: @composition_behavior_kinds

  @spec inline_rich_text_heading(
          String.t() | atom(),
          atom(),
          [keyword() | map()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def inline_rich_text_heading(id, level, segments, opts \\ [])
      when is_atom(level) and is_list(segments) do
    component_widget(
      :inline_rich_text_heading,
      id,
      %{heading: %{level: level, segments: normalize_maps(segments)}},
      [],
      opts
    )
  end

  @spec disclosure(
          String.t() | atom(),
          String.t(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def disclosure(id, summary, children \\ [], opts \\ []) when is_binary(summary) do
    opts = options(opts)

    component_widget(
      :disclosure,
      id,
      %{disclosure: %{summary: summary, open?: Builder.option(opts, :open?, false)}},
      children,
      opts,
      on_open: :open,
      on_close: :close
    )
  end

  @spec kicker(String.t() | atom(), [String.t()], keyword() | map()) :: ElmUi.Widget.t()
  def kicker(id, items, opts \\ []) when is_list(items) do
    opts = options(opts)

    component_widget(
      :kicker,
      id,
      %{kicker: %{items: items, separator: Builder.option(opts, :separator, "·")}},
      [],
      opts
    )
  end

  @spec avatar(String.t() | atom(), keyword() | map()) :: ElmUi.Widget.t()
  def avatar(id, opts \\ []) do
    opts = options(opts)

    component_widget(
      :avatar,
      id,
      %{
        identity:
          %{}
          |> maybe_put(:initials, Builder.option(opts, :initials))
          |> maybe_put(:image_source, Builder.option(opts, :image_source))
          |> maybe_put(:size, Builder.option(opts, :size, :medium))
          |> maybe_put(:shape, Builder.option(opts, :shape, :round))
      },
      [],
      opts
    )
  end

  @spec presence_dot(String.t() | atom(), atom(), keyword() | map()) :: ElmUi.Widget.t()
  def presence_dot(id, state, opts \\ []) when is_atom(state) do
    opts = options(opts)

    component_widget(
      :presence_dot,
      id,
      %{presence: %{state: state, size: Builder.option(opts, :size, :medium)}},
      [],
      opts
    )
  end

  @spec segmented_button_group(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def segmented_button_group(id, options_list, opts \\ []) when is_list(options_list) do
    opts = options(opts)

    component_widget(
      :segmented_button_group,
      id,
      %{
        selection:
          %{
            presentation: :segmented_button_group,
            multiple?: false,
            options: normalize_options(options_list)
          }
          |> maybe_put(:active_value, Builder.option(opts, :active_value))
          |> maybe_put(:selection_intent, Builder.option(opts, :selection_intent))
      },
      [],
      opts,
      on_select: :selection,
      on_selection: :selection,
      on_change: :change
    )
  end

  @spec runtime_form_shell(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def runtime_form_shell(id, fields, opts \\ []) when is_list(fields) do
    opts = options(opts)

    component_widget(
      :runtime_form_shell,
      id,
      %{
        form:
          %{
            fields: normalize_maps(fields)
          }
          |> maybe_put(:submit_label, Builder.option(opts, :submit_label))
          |> maybe_put(:submit_intent, Builder.option(opts, :submit_intent))
          |> maybe_put(:change_intent, Builder.option(opts, :change_intent))
          |> maybe_put(:validation_state, Builder.option(opts, :validation_state))
          |> maybe_put(
            :host_adapter_hints,
            normalize_optional_map(Builder.option(opts, :host_adapter_hints))
          )
      },
      Builder.option(opts, :children, []),
      opts,
      on_submit: :submit,
      on_change: :change
    )
  end

  @spec chat_composer(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def chat_composer(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :chat_composer,
      id,
      %{
        composer:
          %{}
          |> maybe_put(:name, Builder.option(opts, :name))
          |> maybe_put(:value, Builder.option(opts, :value))
          |> maybe_put(:placeholder, Builder.option(opts, :placeholder))
          |> maybe_put(:rows, Builder.option(opts, :rows, 3))
          |> maybe_put(:send_label, Builder.option(opts, :send_label, "Send"))
          |> maybe_put(:send_intent, Builder.option(opts, :send_intent))
          |> maybe_put(:change_intent, Builder.option(opts, :change_intent))
      },
      children,
      opts,
      on_send: :submit,
      on_submit: :submit,
      on_change: :change
    )
  end

  @spec list_item_multi_column(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def list_item_multi_column(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :list_item_multi_column,
      id,
      %{
        row:
          common_row_attrs(opts)
          |> maybe_put(
            :column_template,
            normalize_maps(Builder.option(opts, :column_template, []))
          )
      },
      children,
      opts,
      on_activate: :click,
      on_click: :click,
      on_select: :selection
    )
  end

  @spec artifact_row(
          String.t() | atom(),
          String.t(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def artifact_row(id, title, children \\ [], opts \\ [])
      when is_binary(title) and is_list(children) do
    opts = options(opts)

    component_widget(
      :artifact_row,
      id,
      %{
        artifact:
          common_row_attrs(opts)
          |> maybe_put(:title, title)
          |> maybe_put(:meta, Builder.option(opts, :meta))
      },
      children,
      opts,
      on_activate: :click,
      on_click: :click,
      on_select: :selection
    )
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) when is_list(steps) do
    opts = options(opts)

    component_widget(
      :pipeline_stepper_horizontal,
      id,
      %{
        workflow:
          %{
            presentation: :pipeline_stepper_horizontal,
            steps: normalize_maps(steps),
            active_index: Builder.option(opts, :active_index, 0),
            completed_indices: Builder.option(opts, :completed_indices, [])
          }
          |> maybe_put(:navigation_intent, Builder.option(opts, :navigation_intent))
      },
      [],
      opts,
      on_step: :navigation,
      on_navigate: :navigation
    )
  end

  @spec segmented_progress_bar(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) when is_list(segments) do
    opts = options(opts)

    component_widget(
      :segmented_progress_bar,
      id,
      %{
        progress:
          %{
            presentation: :segmented_progress_bar,
            segments: normalize_maps(segments)
          }
          |> maybe_put(
            :aggregate,
            normalize_optional_map(Builder.option(opts, :aggregate_progress))
          )
          |> maybe_put(:label, Builder.option(opts, :label))
      },
      [],
      opts
    )
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) when is_list(stages) do
    opts = options(opts)

    component_widget(
      :workflow_stage_list_vertical,
      id,
      %{
        workflow: %{
          presentation: :workflow_stage_list_vertical,
          stages: normalize_maps(stages),
          active_index: Builder.option(opts, :active_index, 0)
        }
      },
      [],
      opts,
      on_step: :navigation,
      on_navigate: :navigation
    )
  end

  @spec meter_thin(String.t() | atom(), number(), keyword() | map()) :: ElmUi.Widget.t()
  def meter_thin(id, current, opts \\ []) when is_number(current) do
    opts = options(opts)

    component_widget(
      :meter_thin,
      id,
      %{
        meter:
          %{
            current: current,
            minimum: Builder.option(opts, :minimum, 0),
            maximum: Builder.option(opts, :maximum, 100)
          }
          |> maybe_put(:label, Builder.option(opts, :label))
          |> maybe_put(:state, Builder.option(opts, :state))
      },
      [],
      opts
    )
  end

  @spec sticky_frosted_header(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def sticky_frosted_header(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :sticky_frosted_header,
      id,
      %{
        shell:
          %{
            position: :sticky,
            visual_effect: :frosted
          }
          |> maybe_put(:title, Builder.option(opts, :title))
          |> maybe_put(:leading, Builder.option(opts, :leading, []))
          |> maybe_put(:trailing, Builder.option(opts, :trailing, []))
      },
      children,
      opts
    )
  end

  @spec slide_over_panel(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :slide_over_panel,
      id,
      %{
        panel:
          %{
            modal?: false,
            open?: Builder.option(opts, :open?, false),
            size: Builder.option(opts, :size, :medium)
          }
          |> maybe_put(
            :label,
            Builder.option(opts, :label, Builder.option(opts, :accessibility_label))
          )
          |> maybe_put(:dismiss_intent, Builder.option(opts, :dismiss_intent))
      },
      children,
      opts,
      on_open: :open,
      on_close: :close,
      on_dismiss: :close
    )
  end

  @spec event_callout(
          String.t() | atom(),
          String.t(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def event_callout(id, message, children \\ [], opts \\ [])
      when is_binary(message) and is_list(children) do
    opts = options(opts)

    component_widget(
      :event_callout,
      id,
      %{
        callout:
          %{
            message: message,
            tone: Builder.option(opts, :tone, :info)
          }
          |> maybe_put(:eyebrow, Builder.option(opts, :eyebrow))
          |> maybe_put(:title, Builder.option(opts, :title))
          |> maybe_put(:action_intent, Builder.option(opts, :action_intent))
      },
      children,
      opts,
      on_action: :click,
      on_click: :click
    )
  end

  @spec redline_inline(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          ElmUi.Widget.t()
  def redline_inline(id, segments, opts \\ []) when is_list(segments) do
    opts = options(opts)

    component_widget(
      :redline_inline,
      id,
      %{
        redline: %{segments: normalize_maps(segments)},
        text_safety: %{content: Builder.option(opts, :text_safety, :plain_text)}
      },
      [],
      opts
    )
  end

  @spec code_block_syntax_highlighted(
          String.t() | atom(),
          atom() | String.t(),
          [keyword() | map()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def code_block_syntax_highlighted(id, language, tokens, opts \\ [])
      when (is_atom(language) or is_binary(language)) and is_list(tokens) do
    opts = options(opts)

    component_widget(
      :code_block_syntax_highlighted,
      id,
      %{
        code: %{language: language, tokens: normalize_maps(tokens)},
        text_safety: %{content: Builder.option(opts, :text_safety, :plain_text)}
      },
      [],
      opts
    )
  end

  @spec list_repeat(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          ElmUi.Widget.t()
  def list_repeat(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :list_repeat,
      id,
      %{
        repeat: %{
          binding_id: Builder.option(opts, :repeat_binding),
          row_scope: Builder.option(opts, :row_scope, :row),
          row_fields: Builder.option(opts, :row_fields, []),
          identity_strategy: Builder.option(opts, :identity_strategy, :row_identity),
          child_slot: Builder.option(opts, :child_slot, :default),
          hydrated?: Builder.option(opts, :hydrated?, false),
          row_count: Builder.option(opts, :row_count, length(children))
        }
      },
      children,
      opts
    )
  end

  @spec mode_nav(String.t() | atom(), [keyword() | map()], keyword() | map()) :: ElmUi.Widget.t()
  def mode_nav(id, items, opts \\ []) when is_list(items) do
    opts = options(opts)

    component_widget(
      :mode_nav,
      id,
      %{
        navigation:
          %{items: normalize_maps(items)}
          |> maybe_put(:aria_label, Builder.option(opts, :aria_label))
          |> maybe_put(:navigation_intent, Builder.option(opts, :navigation_intent))
      },
      [],
      opts,
      on_navigate: :navigation
    )
  end

  @spec unread_badge(String.t() | atom(), non_neg_integer(), keyword() | map()) ::
          ElmUi.Widget.t()
  def unread_badge(id, count, opts \\ []) when is_integer(count) and count >= 0 do
    opts = options(opts)

    component_widget(
      :unread_badge,
      id,
      %{
        status: %{
          count: count,
          threshold: Builder.option(opts, :threshold, 99)
        }
      },
      [],
      opts
    )
  end

  @spec top_strip(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def top_strip(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :top_strip,
      id,
      %{
        shell: %{
          position: :top,
          brand: Builder.option(opts, :brand, ""),
          context: Builder.option(opts, :context, ""),
          theme: Builder.option(opts, :theme, :light),
          pane_open?: Builder.option(opts, :pane_open?, false)
        }
      },
      children,
      opts
    )
  end

  @spec sidebar_shell(
          String.t() | atom(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def sidebar_shell(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_shell,
      id,
      %{shell: %{position: :side, collapsed?: Builder.option(opts, :collapsed?, false)}},
      children,
      opts
    )
  end

  @spec sidebar_section(
          String.t() | atom(),
          String.t(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def sidebar_section(id, label, children \\ [], opts \\ [])
      when is_binary(label) and is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_section,
      id,
      %{
        section:
          %{label: label}
          |> maybe_put(:action_glyph, Builder.option(opts, :action_glyph))
          |> maybe_put(:action_label, Builder.option(opts, :action_label))
          |> maybe_put(:action_intent, Builder.option(opts, :action_intent))
      },
      children,
      opts
    )
  end

  @spec sidebar_item(
          String.t() | atom(),
          String.t(),
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def sidebar_item(id, label, children \\ [], opts \\ [])
      when is_binary(label) and is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_item,
      id,
      %{
        item:
          %{label: label, selected?: Builder.option(opts, :selected?, false)}
          |> maybe_put(:item_intent, Builder.option(opts, :item_intent))
      },
      children,
      opts,
      on_select: :selection,
      on_click: :click
    )
  end

  @spec command_palette(
          String.t() | atom(),
          [keyword() | map()],
          [ElmUi.Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def command_palette(id, items \\ [], children \\ [], opts \\ [])
      when is_list(items) and is_list(children) do
    opts = options(opts)

    component_widget(
      :command_palette,
      id,
      %{
        palette:
          %{open?: Builder.option(opts, :open?, false), items: normalize_maps(items)}
          |> maybe_put(:filter_intent, Builder.option(opts, :filter_intent))
          |> maybe_put(:select_intent, Builder.option(opts, :select_intent))
      },
      children,
      opts,
      on_filter: :filter,
      on_select: :select
    )
  end

  @spec from_iur(
          atom(),
          String.t() | atom() | nil,
          map(),
          %{optional(atom() | String.t()) => [ElmUi.Widget.t()]},
          keyword() | map()
        ) :: ElmUi.Widget.t()
  def from_iur(kind, id, attributes, slot_children, opts \\ [])
      when is_atom(kind) and is_map(attributes) and is_map(slot_children) do
    opts = options(opts)
    component_family = family_for_kind(kind)

    Builder.widget(kind,
      id: id,
      family: :component,
      attributes: attributes,
      slot_children: slot_children,
      state: Builder.option(opts, :state, component_state(attributes)),
      styles: Builder.option(opts, :styles, %{}),
      events: Builder.option(opts, :events, %{}),
      metadata:
        Builder.option(opts, :metadata, %{})
        |> Map.merge(%{
          native_surface: :component,
          component_family: component_family
        })
    )
  end

  defp component_widget(kind, id, attributes, children, opts, event_shorthand \\ []) do
    opts = options(Map.put(options(opts), :id, id))
    component_family = family_for_kind(kind)

    Builder.widget(kind,
      id: id,
      family: :component,
      attributes:
        attributes
        |> Map.put_new(:component, %{family: component_family, kind: kind})
        |> merge_optional_attribute(:accessibility, accessibility(opts))
        |> merge_optional_attribute(:state, component_state(opts)),
      slot_children: Builder.slot_map([{:default, children}]),
      state: component_state(opts),
      styles: Builder.styles(opts),
      events: Builder.events(opts, event_shorthand),
      metadata:
        Builder.metadata(opts, %{
          native_surface: :component,
          component_family: component_family
        })
    )
  end

  defp common_row_attrs(opts) do
    %{}
    |> maybe_put(:row_identity, Builder.option(opts, :row_identity))
    |> maybe_put(:active?, Builder.option(opts, :active?))
    |> maybe_put(:link_target, Builder.option(opts, :link_target))
    |> maybe_put(:action_intent, Builder.option(opts, :action_intent))
  end

  defp component_state(opts) when is_map(opts) do
    opts
    |> Builder.state([:disabled, :selected, :active, :open, :focused, :editing, :loading])
    |> maybe_put(:disabled?, Builder.option(opts, :disabled?))
    |> maybe_put(:active?, Builder.option(opts, :active?))
    |> maybe_put(:open?, Builder.option(opts, :open?))
  end

  defp accessibility(opts) do
    %{}
    |> maybe_put(:label, Builder.option(opts, :accessibility_label))
    |> maybe_put(:description, Builder.option(opts, :accessibility_description))
    |> maybe_put(:role, Builder.option(opts, :accessibility_role))
  end

  defp normalize_options(options) do
    Enum.map(options, fn option ->
      option = options(option)

      %{}
      |> maybe_put(:value, Builder.option(option, :value))
      |> maybe_put(:label, Builder.option(option, :label))
      |> maybe_put(:disabled?, Builder.option(option, :disabled?))
    end)
  end

  defp normalize_maps(values) when is_list(values), do: Enum.map(values, &options/1)
  defp normalize_maps(_values), do: []

  defp normalize_optional_map(nil), do: nil
  defp normalize_optional_map(value), do: options(value)

  defp options(opts), do: Builder.options(opts)

  defp merge_optional_attribute(attributes, _key, value) when value in [%{}, [], nil],
    do: attributes

  defp merge_optional_attribute(attributes, key, value), do: Map.put(attributes, key, value)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
