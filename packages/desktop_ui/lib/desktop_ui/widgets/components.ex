defmodule DesktopUi.Widgets.Components do
  @moduledoc """
  Desktop-native widget models for the expanded canonical component catalog.
  """

  alias DesktopUi.Widget

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

  @row_artifact_kinds [:list_item_multi_column, :artifact_row]

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

  @redline_code_kinds [:redline_inline, :code_block_syntax_highlighted]
  @composition_behavior_kinds [:list_repeat]

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

  @focusable_kinds [
    :disclosure,
    :segmented_button_group,
    :runtime_form_shell,
    :chat_composer,
    :list_item_multi_column,
    :artifact_row,
    :pipeline_stepper_horizontal,
    :workflow_stage_list_vertical,
    :slide_over_panel,
    :event_callout,
    :mode_nav,
    :sidebar_item,
    :command_palette
  ]

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

  @spec inline_rich_text_heading(
          String.t() | atom(),
          atom(),
          [keyword() | map()],
          keyword() | map()
        ) ::
          Widget.t()
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
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          Widget.t()
  def disclosure(id, summary, children \\ [], opts \\ []) when is_binary(summary) do
    opts = options(opts)

    component_widget(
      :disclosure,
      id,
      %{disclosure: %{summary: summary, open?: option(opts, :open?, false)}},
      children,
      opts,
      on_open: :open,
      on_close: :close
    )
  end

  @spec kicker(String.t() | atom(), [String.t()], keyword() | map()) :: Widget.t()
  def kicker(id, items, opts \\ []) when is_list(items) do
    opts = options(opts)

    component_widget(
      :kicker,
      id,
      %{kicker: %{items: items, separator: option(opts, :separator, "·")}},
      [],
      opts
    )
  end

  @spec avatar(String.t() | atom(), keyword() | map()) :: Widget.t()
  def avatar(id, opts \\ []) do
    opts = options(opts)

    component_widget(
      :avatar,
      id,
      %{
        identity:
          %{}
          |> maybe_put(:initials, option(opts, :initials))
          |> maybe_put(:image_source, option(opts, :image_source))
          |> maybe_put(:size, option(opts, :size, :medium))
          |> maybe_put(:shape, option(opts, :shape, :round))
      },
      [],
      opts
    )
  end

  @spec presence_dot(String.t() | atom(), atom(), keyword() | map()) :: Widget.t()
  def presence_dot(id, state, opts \\ []) when is_atom(state) do
    opts = options(opts)

    component_widget(
      :presence_dot,
      id,
      %{presence: %{state: state, size: option(opts, :size, :medium)}},
      [],
      opts
    )
  end

  @spec segmented_button_group(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          Widget.t()
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
          |> maybe_put(:active_value, option(opts, :active_value))
          |> maybe_put(:selection_intent, option(opts, :selection_intent))
      },
      [],
      opts,
      on_select: :selection,
      on_change: :change
    )
  end

  @spec runtime_form_shell(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          Widget.t()
  def runtime_form_shell(id, fields, opts \\ []) when is_list(fields) do
    opts = options(opts)

    component_widget(
      :runtime_form_shell,
      id,
      %{
        form:
          %{fields: normalize_maps(fields)}
          |> maybe_put(:submit_label, option(opts, :submit_label))
          |> maybe_put(:submit_intent, option(opts, :submit_intent))
          |> maybe_put(:change_intent, option(opts, :change_intent))
          |> maybe_put(:validation_state, option(opts, :validation_state))
          |> maybe_put(
            :host_adapter_hints,
            normalize_optional_map(option(opts, :host_adapter_hints))
          )
      },
      option(opts, :children, []),
      opts,
      on_submit: :submit,
      on_change: :change
    )
  end

  @spec chat_composer(String.t() | atom(), [Widget.t() | map() | keyword()], keyword() | map()) ::
          Widget.t()
  def chat_composer(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :chat_composer,
      id,
      %{
        composer:
          %{}
          |> maybe_put(:name, option(opts, :name))
          |> maybe_put(:value, option(opts, :value))
          |> maybe_put(:placeholder, option(opts, :placeholder))
          |> maybe_put(:rows, option(opts, :rows, 3))
          |> maybe_put(:send_label, option(opts, :send_label, "Send"))
          |> maybe_put(:send_intent, option(opts, :send_intent))
          |> maybe_put(:change_intent, option(opts, :change_intent))
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
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          Widget.t()
  def list_item_multi_column(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :list_item_multi_column,
      id,
      %{
        row:
          common_row_attrs(opts)
          |> maybe_put(:column_template, normalize_maps(option(opts, :column_template, [])))
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
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          Widget.t()
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
          |> maybe_put(:meta, option(opts, :meta))
      },
      children,
      opts,
      on_activate: :click,
      on_click: :click,
      on_select: :selection
    )
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          Widget.t()
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
            active_index: option(opts, :active_index, 0),
            completed_indices: option(opts, :completed_indices, [])
          }
          |> maybe_put(:navigation_intent, option(opts, :navigation_intent))
      },
      [],
      opts,
      on_step: :navigation,
      on_navigate: :navigation
    )
  end

  @spec segmented_progress_bar(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) when is_list(segments) do
    opts = options(opts)

    component_widget(
      :segmented_progress_bar,
      id,
      %{
        progress:
          %{presentation: :segmented_progress_bar, segments: normalize_maps(segments)}
          |> maybe_put(:aggregate, normalize_optional_map(option(opts, :aggregate_progress)))
          |> maybe_put(:label, option(opts, :label))
      },
      [],
      opts
    )
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), [keyword() | map()], keyword() | map()) ::
          Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) when is_list(stages) do
    opts = options(opts)

    component_widget(
      :workflow_stage_list_vertical,
      id,
      %{
        workflow: %{
          presentation: :workflow_stage_list_vertical,
          stages: normalize_maps(stages),
          active_index: option(opts, :active_index, 0)
        }
      },
      [],
      opts,
      on_step: :navigation,
      on_navigate: :navigation
    )
  end

  @spec meter_thin(String.t() | atom(), number(), keyword() | map()) :: Widget.t()
  def meter_thin(id, current, opts \\ []) when is_number(current) do
    opts = options(opts)

    component_widget(
      :meter_thin,
      id,
      %{
        meter:
          %{
            current: current,
            minimum: option(opts, :minimum, 0),
            maximum: option(opts, :maximum, 100)
          }
          |> maybe_put(:label, option(opts, :label))
          |> maybe_put(:state, option(opts, :state))
      },
      [],
      opts
    )
  end

  @spec sticky_frosted_header(
          String.t() | atom(),
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          Widget.t()
  def sticky_frosted_header(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :sticky_frosted_header,
      id,
      %{
        shell:
          %{position: :sticky, visual_effect: :frosted}
          |> maybe_put(:title, option(opts, :title))
          |> maybe_put(:leading, option(opts, :leading, []))
          |> maybe_put(:trailing, option(opts, :trailing, []))
      },
      children,
      opts
    )
  end

  @spec slide_over_panel(String.t() | atom(), [Widget.t() | map() | keyword()], keyword() | map()) ::
          Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :slide_over_panel,
      id,
      %{
        panel:
          %{modal?: false, open?: option(opts, :open?, false), size: option(opts, :size, :medium)}
          |> maybe_put(:label, option(opts, :label, option(opts, :accessibility_label)))
          |> maybe_put(:dismiss_intent, option(opts, :dismiss_intent))
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
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) ::
          Widget.t()
  def event_callout(id, message, children \\ [], opts \\ [])
      when is_binary(message) and is_list(children) do
    opts = options(opts)

    component_widget(
      :event_callout,
      id,
      %{
        callout:
          %{message: message, tone: option(opts, :tone, :info)}
          |> maybe_put(:eyebrow, option(opts, :eyebrow))
          |> maybe_put(:title, option(opts, :title))
          |> maybe_put(:action_intent, option(opts, :action_intent))
      },
      children,
      opts,
      on_action: :click,
      on_click: :click
    )
  end

  @spec redline_inline(String.t() | atom(), [keyword() | map()], keyword() | map()) :: Widget.t()
  def redline_inline(id, segments, opts \\ []) when is_list(segments) do
    opts = options(opts)

    component_widget(
      :redline_inline,
      id,
      %{
        redline: %{segments: normalize_maps(segments)},
        text_safety: %{content: option(opts, :text_safety, :plain_text)}
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
          Widget.t()
  def code_block_syntax_highlighted(id, language, tokens, opts \\ [])
      when (is_atom(language) or is_binary(language)) and is_list(tokens) do
    opts = options(opts)

    component_widget(
      :code_block_syntax_highlighted,
      id,
      %{
        code: %{language: language, tokens: normalize_maps(tokens)},
        text_safety: %{content: option(opts, :text_safety, :plain_text)}
      },
      [],
      opts
    )
  end

  @spec list_repeat(String.t() | atom(), [Widget.t() | map() | keyword()], keyword() | map()) ::
          Widget.t()
  def list_repeat(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :list_repeat,
      id,
      %{
        repeat: %{
          binding_id: option(opts, :repeat_binding),
          row_scope: option(opts, :row_scope, :row),
          row_fields: option(opts, :row_fields, []),
          identity_strategy: option(opts, :identity_strategy, :row_identity),
          child_slot: option(opts, :child_slot, :default),
          hydrated?: option(opts, :hydrated?, false),
          row_count: option(opts, :row_count, length(children))
        }
      },
      children,
      opts
    )
  end

  @spec mode_nav(String.t() | atom(), [keyword() | map()], keyword() | map()) :: Widget.t()
  def mode_nav(id, items, opts \\ []) when is_list(items) do
    opts = options(opts)

    component_widget(
      :mode_nav,
      id,
      %{
        navigation:
          %{items: normalize_maps(items)}
          |> maybe_put(:aria_label, option(opts, :aria_label))
          |> maybe_put(:navigation_intent, option(opts, :navigation_intent))
      },
      [],
      opts,
      on_navigate: :navigation
    )
  end

  @spec unread_badge(String.t() | atom(), non_neg_integer(), keyword() | map()) :: Widget.t()
  def unread_badge(id, count, opts \\ []) when is_integer(count) and count >= 0 do
    opts = options(opts)

    component_widget(
      :unread_badge,
      id,
      %{status: %{count: count, threshold: option(opts, :threshold, 99)}},
      [],
      opts
    )
  end

  @spec top_strip(String.t() | atom(), [Widget.t() | map() | keyword()], keyword() | map()) ::
          Widget.t()
  def top_strip(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :top_strip,
      id,
      %{
        shell: %{
          position: :top,
          brand: option(opts, :brand, ""),
          context: option(opts, :context, ""),
          theme: option(opts, :theme, :light),
          pane_open?: option(opts, :pane_open?, false)
        }
      },
      children,
      opts
    )
  end

  @spec sidebar_shell(String.t() | atom(), [Widget.t() | map() | keyword()], keyword() | map()) ::
          Widget.t()
  def sidebar_shell(id, children \\ [], opts \\ []) when is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_shell,
      id,
      %{shell: %{position: :side, collapsed?: option(opts, :collapsed?, false)}},
      children,
      opts
    )
  end

  @spec sidebar_section(
          String.t() | atom(),
          String.t(),
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: Widget.t()
  def sidebar_section(id, label, children \\ [], opts \\ [])
      when is_binary(label) and is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_section,
      id,
      %{
        section:
          %{label: label}
          |> maybe_put(:action_glyph, option(opts, :action_glyph))
          |> maybe_put(:action_label, option(opts, :action_label))
          |> maybe_put(:action_intent, option(opts, :action_intent))
      },
      children,
      opts
    )
  end

  @spec sidebar_item(
          String.t() | atom(),
          String.t(),
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: Widget.t()
  def sidebar_item(id, label, children \\ [], opts \\ [])
      when is_binary(label) and is_list(children) do
    opts = options(opts)

    component_widget(
      :sidebar_item,
      id,
      %{
        item:
          %{label: label, selected?: option(opts, :selected?, false)}
          |> maybe_put(:item_intent, option(opts, :item_intent))
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
          [Widget.t() | map() | keyword()],
          keyword() | map()
        ) :: Widget.t()
  def command_palette(id, items \\ [], children \\ [], opts \\ [])
      when is_list(items) and is_list(children) do
    opts = options(opts)

    component_widget(
      :command_palette,
      id,
      %{
        palette:
          %{open?: option(opts, :open?, false), items: normalize_maps(items)}
          |> maybe_put(:filter_intent, option(opts, :filter_intent))
          |> maybe_put(:select_intent, option(opts, :select_intent))
      },
      children,
      opts,
      on_filter: :filter,
      on_select: :select
    )
  end

  @spec from_iur(atom(), String.t() | atom(), map(), keyword() | map()) :: Widget.t()
  def from_iur(kind, id, attributes, opts \\ []) when is_atom(kind) and is_map(attributes) do
    opts = options(opts)
    family = family_for_kind(kind)

    Widget.new(kind,
      id: id,
      family: :component,
      metadata:
        metadata(opts, kind, family)
        |> Map.merge(normalize_map(option(opts, :metadata, %{}))),
      state: option(opts, :state, component_state(attributes)),
      bindings: normalize_map(option(opts, :bindings, %{})),
      attributes: attributes,
      styles: component_styles(kind, family, opts),
      events: normalize_map(option(opts, :events, %{}))
    )
  end

  defp component_widget(kind, id, attributes, children, opts, event_shorthand \\ []) do
    opts = options(opts)
    family = family_for_kind(kind)

    Widget.new(kind,
      id: id,
      family: :component,
      metadata: metadata(opts, kind, family),
      state: component_state(opts),
      attributes:
        attributes
        |> Map.put_new(:component, %{family: family, kind: kind})
        |> merge_optional_attribute(:accessibility, accessibility(opts))
        |> merge_optional_attribute(:state, component_state(opts)),
      styles: component_styles(kind, family, opts),
      events: events(opts, event_shorthand),
      slot_children: %{default: normalize_children(children)}
    )
  end

  defp metadata(opts, kind, family) do
    %{
      native_surface: :component,
      component_family: family,
      component_kind: kind,
      focusable: option(opts, :focusable, kind in @focusable_kinds),
      interaction_route: :desktop_widget_component
    }
    |> maybe_put(:label, option(opts, :accessibility_label, option(opts, :label)))
    |> maybe_put(:description, option(opts, :description))
    |> maybe_put(:role, option(opts, :role))
  end

  defp component_styles(kind, family, opts) do
    opts
    |> option(:styles, %{})
    |> normalize_map()
    |> Map.put_new(:component_kind, kind)
    |> Map.put_new(:component_family, family)
  end

  defp component_state(source) when is_map(source) do
    source
    |> option(:state, %{})
    |> normalize_map()
    |> maybe_put(:disabled, option(source, :disabled))
    |> maybe_put(:disabled?, option(source, :disabled?))
    |> maybe_put(:active?, option(source, :active?))
    |> maybe_put(:open?, option(source, :open?))
    |> maybe_put(:open, option(source, :open))
  end

  defp common_row_attrs(opts) do
    %{}
    |> maybe_put(:row_identity, option(opts, :row_identity))
    |> maybe_put(:active?, option(opts, :active?))
    |> maybe_put(:link_target, option(opts, :link_target))
    |> maybe_put(:action_intent, option(opts, :action_intent))
  end

  defp accessibility(opts) do
    %{}
    |> maybe_put(:label, option(opts, :accessibility_label))
    |> maybe_put(:description, option(opts, :accessibility_description))
  end

  defp normalize_options(options) do
    Enum.map(options, fn option ->
      option = options(option)

      %{}
      |> maybe_put(:value, option(option, :value))
      |> maybe_put(:label, option(option, :label))
      |> maybe_put(:disabled?, option(option, :disabled?))
    end)
  end

  defp normalize_maps(values) when is_list(values), do: Enum.map(values, &normalize_map/1)
  defp normalize_maps(_values), do: []

  defp normalize_optional_map(nil), do: nil
  defp normalize_optional_map(value), do: normalize_map(value)

  defp normalize_children(children) do
    Enum.map(List.wrap(children), fn
      %Widget{} = child ->
        child

      child when is_map(child) ->
        Widget.new(Map.get(child, :kind, :text), child)

      child when is_list(child) ->
        child |> Map.new() |> then(&Widget.new(Map.get(&1, :kind, :text), &1))
    end)
  end

  defp events(opts, shorthand) do
    base = opts |> option(:events, %{}) |> normalize_map()

    Enum.reduce(shorthand, base, fn {key, event_name}, acc ->
      maybe_put(acc, event_name, option(opts, key))
    end)
  end

  defp options(value) when is_map(value), do: Map.new(value)
  defp options(value) when is_list(value), do: Map.new(value)

  defp option(map, key, default \\ nil) when is_map(map) do
    Map.get(map, key, Map.get(map, Atom.to_string(key), default))
  end

  defp normalize_map(nil), do: %{}
  defp normalize_map(%_{} = struct), do: struct |> Map.from_struct() |> normalize_map()

  defp normalize_map(map) when is_map(map),
    do: Map.new(map, fn {key, value} -> {key, normalize_value(value)} end)

  defp normalize_map(list) when is_list(list), do: list |> Map.new() |> normalize_map()

  defp normalize_value(%_{} = struct), do: struct |> Map.from_struct() |> normalize_map()
  defp normalize_value(map) when is_map(map), do: normalize_map(map)
  defp normalize_value(list) when is_list(list), do: Enum.map(list, &normalize_value/1)
  defp normalize_value(value), do: value

  defp merge_optional_attribute(attributes, _key, value) when value in [%{}, [], nil],
    do: attributes

  defp merge_optional_attribute(attributes, key, value), do: Map.put(attributes, key, value)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
