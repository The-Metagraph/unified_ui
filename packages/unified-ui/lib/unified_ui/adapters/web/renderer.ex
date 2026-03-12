defmodule UnifiedUi.Adapters.Web do
  @moduledoc """
  Web renderer that converts IUR to HTML/CSS and HEEx-compatible template
  strings.

  This renderer implements the `UnifiedUi.Renderer` behaviour and converts
  Intermediate UI Representation (IUR) elements to HTML strings with inline
  CSS styles and Phoenix LiveView event bindings.

  ## Usage

      # Create an IUR tree
      iur = %VBox{
        children: [
          %Text{content: "Hello"},
          %Button{label: "Click Me", on_click: :clicked}
        ]
      }

      # Render to HTML (default)
      {:ok, state} = Web.render(iur)

      # Render to HEEx-compatible output
      {:ok, heex_template} = Web.render_heex(iur)

  ## Output Formats

  The renderer supports:
  * HTML output (`:format` = `:html`, default)
  * HEEx-compatible output (`:format` = `:heex` or `:template` = `:heex`)

  Both formats produce semantic markup with:
  * Semantic HTML5 elements
  * Inline CSS styles
  * Phoenix LiveView phx-event bindings

  ## Style Conversion

  IUR styles are converted to CSS inline styles via `Style.to_css/1`.

  ## Layout Mapping

  * `VBox` → `<div style="display: flex; flex-direction: column; ...">`
  * `HBox` → `<div style="display: flex; flex-direction: row; ...">`

  ## Widget Mapping

  * `Text` → `<span>` with text content and style
  * `Button` → `<button>` with label, phx-click binding
  * `Label` → `<label>` with text, for attribute
  * `TextInput` → `<input>` with type, placeholder, phx-change binding

  ## Phoenix LiveView Integration

  Event handlers are converted to Phoenix LiveView bindings:
  * `on_click: :submit` → `phx-click="submit"`
  * `on_change: :update` → `phx-change="update"`

  """

  @behaviour UnifiedUi.Renderer

  alias UnifiedUi.Adapters.State
  alias UnifiedUi.Adapters.Web.Style

  alias UnifiedUi.Widgets.{
    Canvas,
    Command,
    CommandPalette,
    Grid,
    LogViewer,
    ProcessMonitor,
    Stack,
    SplitPane,
    StreamWidget,
    Viewport,
    ZBox
  }

  alias UnifiedIUR.Element
  alias UnifiedIUR.Widgets
  alias UnifiedIUR.Layouts

  @type output_format :: :html | :heex

  @impl true
  @spec render(UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def render(iur_tree, opts \\ []) do
    renderer_state = State.new(:web, config: opts)
    format = output_format(opts)

    # Convert IUR tree to requested output format
    root = render_output(iur_tree, renderer_state, format)

    root_layout_children_render_cache =
      root_layout_children_render_cache(iur_tree, renderer_state)

    root_layout_children_rendered = render_cache_html_list(root_layout_children_render_cache)

    # Update state with root reference and metadata for diff-aware updates
    renderer_state =
      renderer_state
      |> State.put_root(root)
      |> State.put_metadata(:last_iur, iur_tree)
      |> State.put_metadata(:output_format, format)
      |> State.put_metadata(:root_layout_children_rendered, root_layout_children_rendered)
      |> State.put_metadata(:root_layout_children_render_cache, root_layout_children_render_cache)

    {:ok, renderer_state}
  end

  @doc """
  Renders an IUR tree to a HEEx-compatible template string.

  This is equivalent to calling `render/2` with `format: :heex`, then returning
  the rendered root string.
  """
  @spec render_heex(UnifiedUi.Renderer.iur_tree(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def render_heex(iur_tree, opts \\ []) do
    opts = Keyword.put(opts, :format, :heex)
    {:ok, state} = render(iur_tree, opts)
    State.get_root(state)
  end

  @impl true
  @spec update(UnifiedUi.Renderer.iur_tree(), State.t(), keyword()) ::
          {:ok, State.t()} | {:error, term()}
  def update(iur_tree, renderer_state, opts \\ []) do
    merged_config = Keyword.merge(renderer_state.config, opts)
    format = output_format(merged_config)
    previous_iur = State.get_metadata(renderer_state, :last_iur, :__missing__)

    previous_rendered_children =
      State.get_metadata(renderer_state, :root_layout_children_rendered, :__missing__)

    previous_render_cache =
      State.get_metadata(renderer_state, :root_layout_children_render_cache, :__missing__)

    config_changed = merged_config != renderer_state.config
    iur_changed = previous_iur != iur_tree

    if iur_changed or config_changed do
      {new_root, incremental_patch, root_layout_children_rendered,
       root_layout_children_render_cache} =
        build_updated_root(
          iur_tree,
          previous_iur,
          previous_rendered_children,
          previous_render_cache,
          renderer_state,
          config_changed,
          format
        )

      root_changed = new_root != renderer_state.root

      updated_state =
        renderer_state
        |> put_config(merged_config)
        |> State.put_metadata(:last_iur, iur_tree)
        |> State.put_metadata(:output_format, format)
        |> State.put_metadata(:incremental_patch, incremental_patch)
        |> State.put_metadata(:root_layout_children_rendered, root_layout_children_rendered)
        |> State.put_metadata(
          :root_layout_children_render_cache,
          root_layout_children_render_cache
        )
        |> maybe_put_root(new_root, root_changed)
        |> maybe_bump_version(root_changed or config_changed)

      {:ok, updated_state}
    else
      {:ok, renderer_state}
    end
  end

  @impl true
  @spec destroy(State.t()) :: :ok
  def destroy(_renderer_state) do
    # HTML is just a string, no cleanup needed
    :ok
  end

  @doc """
  Converts an IUR element to an HTML string.

  ## Parameters

  * `iur_element` - The IUR element to convert
  * `renderer_state` - The renderer state (used for tracking)

  ## Returns

  An HTML string.

  """
  @spec convert_iur(UnifiedUi.Renderer.iur_element(), State.t()) :: String.t()
  def convert_iur(iur_element, renderer_state \\ %State{}) do
    metadata = Element.metadata(iur_element)
    type = metadata.type
    visible = Map.get(metadata, :visible, true)

    # Skip invisible elements
    if visible == false do
      ""
    else
      convert_by_type(iur_element, type, renderer_state)
    end
  end

  # Widget converters

  defp convert_by_type(%Widgets.Text{} = text, :text, _state) do
    content = escape_html(text.content || "")
    style = Style.to_css(text.style)

    attrs =
      build_attributes([
        {"style", style}
      ])

    ~s(<span#{attrs}>#{content}</span>)
  end

  defp convert_by_type(%Widgets.Button{} = button, :button, _state) do
    label = escape_html(button.label || "")
    style = Style.to_css(button.style)

    # Build attributes list
    attrs_list = [
      {"style", style}
    ]

    # Add phx-click binding if on_click is present
    attrs_list =
      if button.on_click do
        event_name = atom_to_event_name(button.on_click)
        [{"phx-click", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add disabled attribute
    attrs_list = if button.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list

    # Add id if present
    attrs_list = if button.id, do: [{"id", button.id} | attrs_list], else: attrs_list

    attrs = build_attributes(attrs_list)

    ~s(<button#{attrs}>#{label}</button>)
  end

  defp convert_by_type(%Widgets.Label{} = label, :label, _state) do
    text = escape_html(label.text || "")
    style = Style.to_css(label.style)

    # Build attributes list
    attrs_list = [
      {"style", style}
    ]

    # Add for attribute if present
    attrs_list =
      if label.for do
        [{"for", label.for} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<label#{attrs}>#{text}</label>)
  end

  defp convert_by_type(%Widgets.TextInput{} = input, :text_input, _state) do
    style = Style.to_css(input.style)

    # Build attributes list
    attrs_list = [
      {"style", style},
      {"type", input_type_to_string(input.type)}
    ]

    # Add id if present
    attrs_list = if input.id, do: [{"id", input.id} | attrs_list], else: attrs_list

    # Add value if present
    attrs_list = if input.value, do: [{"value", input.value} | attrs_list], else: attrs_list

    # Add placeholder if present
    attrs_list =
      if input.placeholder,
        do: [{"placeholder", input.placeholder} | attrs_list],
        else: attrs_list

    # Add phx-change binding if on_change is present
    attrs_list =
      if input.on_change do
        event_name = atom_to_event_name(input.on_change)
        [{"phx-change", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add disabled attribute
    attrs_list = if input.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list

    # Add form_id if present
    attrs_list = if input.form_id, do: [{"form", input.form_id} | attrs_list], else: attrs_list

    attrs = build_attributes(attrs_list)

    # Self-closing input tag
    ~s(<input#{attrs} />)
  end

  # Advanced input widget converters

  defp convert_by_type(%Widgets.PickListOption{} = option, :pick_list_option, _state) do
    attrs_list = [{"value", serialize_option_value(option.value)}]
    attrs_list = if option.id, do: [{"id", option.id} | attrs_list], else: attrs_list
    attrs_list = if option.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list
    attrs = build_attributes(attrs_list)

    label =
      cond do
        is_binary(option.label) -> option.label
        is_nil(option.value) -> ""
        true -> serialize_option_value(option.value)
      end

    ~s(<option#{attrs}>#{escape_html(label)}</option>)
  end

  defp convert_by_type(%Widgets.PickList{} = pick_list, :pick_list, state) do
    style = Style.to_css(pick_list.style)

    select_attrs = [
      {"class", "unified-pick-list-select"},
      {"style", style},
      {"data-searchable", pick_list.searchable},
      {"data-allow-clear", pick_list.allow_clear}
    ]

    select_attrs = if pick_list.id, do: [{"id", pick_list.id} | select_attrs], else: select_attrs

    select_attrs =
      if pick_list.on_select do
        event_name = atom_to_event_name(pick_list.on_select)
        [{"phx-change", event_name} | select_attrs]
      else
        select_attrs
      end

    placeholder_html =
      cond do
        is_binary(pick_list.placeholder) ->
          selected_attr = if is_nil(pick_list.selected), do: ~s( selected="selected"), else: ""
          ~s(<option value=""#{selected_attr}>#{escape_html(pick_list.placeholder)}</option>)

        pick_list.allow_clear ->
          selected_attr = if is_nil(pick_list.selected), do: ~s( selected="selected"), else: ""
          ~s(<option value=""#{selected_attr}></option>)

        true ->
          ""
      end

    options_html =
      pick_list.options
      |> List.wrap()
      |> Enum.map_join("\n", fn option ->
        option =
          case option do
            %Widgets.PickListOption{} = struct_option -> struct_option
            {value, label} -> %Widgets.PickListOption{value: value, label: label}
            attrs when is_map(attrs) -> struct(Widgets.PickListOption, attrs)
            attrs when is_list(attrs) -> struct(Widgets.PickListOption, Enum.into(attrs, %{}))
            other -> %Widgets.PickListOption{value: other, label: serialize_option_value(other)}
          end

        option_html = convert_iur(option, state)
        value_match? = option.value == pick_list.selected

        if value_match? and option_html != "" do
          String.replace(option_html, "<option", ~s(<option selected="selected"), global: false)
        else
          option_html
        end
      end)

    search_html =
      if pick_list.searchable do
        search_id =
          case pick_list.id do
            id when is_atom(id) -> "#{id}_search"
            _ -> nil
          end

        attrs =
          build_attributes([
            {"class", "unified-pick-list-search"},
            {"type", "search"},
            {"placeholder", "Search..."},
            {"id", search_id}
          ])

        ~s(<input#{attrs} />)
      else
        ""
      end

    attrs = build_attributes(select_attrs)

    ~s(<div class="unified-pick-list">#{search_html}<select#{attrs}>#{placeholder_html}#{options_html}</select></div>)
  end

  defp convert_by_type(%Widgets.FormField{} = field, :form_field, _state) do
    style = Style.to_css(field.style)
    field_name = form_field_name(field.name)

    wrapper_attrs =
      build_attributes([
        {"class", "unified-form-field"},
        {"style", style},
        {"data-field-name", field_name},
        {"data-field-type", field.type}
      ])

    label_html =
      if field.label do
        required_suffix = if field.required, do: " *", else: ""

        ~s(<label for="#{escape_html(field_name)}">#{escape_html(field.label)}#{required_suffix}</label>)
      else
        ""
      end

    input_html =
      case field.type do
        :checkbox ->
          attrs =
            build_attributes([
              {"type", "checkbox"},
              {"id", field_name},
              {"name", field_name},
              {"checked", if(field.default in [true, "true", 1], do: "true", else: nil)},
              {"disabled", if(field.disabled, do: "true", else: nil)}
            ])

          ~s(<input#{attrs} />)

        :select ->
          select_attrs =
            build_attributes([
              {"id", field_name},
              {"name", field_name},
              {"required", if(field.required, do: "true", else: nil)},
              {"disabled", if(field.disabled, do: "true", else: nil)}
            ])

          options_html =
            field.options
            |> List.wrap()
            |> Enum.map_join("\n", fn option ->
              {value, label} = normalize_form_option(option)
              selected = if value == field.default, do: ~s( selected="selected"), else: ""

              ~s(<option value="#{escape_html(serialize_option_value(value))}"#{selected}>#{escape_html(label)}</option>)
            end)

          ~s(<select#{select_attrs}>#{options_html}</select>)

        _ ->
          input_type =
            case field.type do
              :password -> "password"
              :email -> "email"
              :number -> "number"
              _ -> "text"
            end

          attrs =
            build_attributes([
              {"type", input_type},
              {"id", field_name},
              {"name", field_name},
              {"placeholder", field.placeholder},
              {"value",
               if(is_nil(field.default), do: nil, else: serialize_option_value(field.default))},
              {"required", if(field.required, do: "true", else: nil)},
              {"disabled", if(field.disabled, do: "true", else: nil)}
            ])

          ~s(<input#{attrs} />)
      end

    ~s(<div#{wrapper_attrs}>#{label_html}#{input_html}</div>)
  end

  defp convert_by_type(%Widgets.FormBuilder{} = form_builder, :form_builder, state) do
    style = Style.to_css(form_builder.style)

    attrs_list = [
      {"class", "unified-form-builder"},
      {"style", style}
    ]

    attrs_list = if form_builder.id, do: [{"id", form_builder.id} | attrs_list], else: attrs_list

    attrs_list =
      if form_builder.on_submit do
        event_name = atom_to_event_name(form_builder.on_submit)
        [{"phx-submit", event_name} | attrs_list]
      else
        attrs_list
      end

    attrs_list =
      if form_builder.action do
        [{"data-action", form_builder.action} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    fields_html =
      form_builder.fields
      |> List.wrap()
      |> Enum.map_join("\n", fn field ->
        convert_iur(field, state)
      end)

    submit_label = escape_html(form_builder.submit_label || "Submit")

    ~s(<form#{attrs}>#{fields_html}<div class="form-actions"><button type="submit">#{submit_label}</button></div></form>)
  end

  # Data visualization converters

  defp convert_by_type(%Widgets.Gauge{} = gauge, :gauge, _state) do
    # Calculate gauge dimensions
    min_val = gauge.min || 0
    max_val = gauge.max || 100
    value = max(min_val, min(max_val, gauge.value))
    range = max_val - min_val
    percentage = if range > 0, do: (value - min_val) / range * 100, else: 0

    width = gauge.width || 200
    height = gauge.height || 20

    # Build SVG gauge
    svg_content = """
    <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="#{width}" height="#{height}" fill="#e0e0e0" rx="4"/>
      <rect x="0" y="0" width="#{width * percentage / 100}" height="#{height}" fill="#4CAF50" rx="4">
        <animate attributeName="width" from="0" to="#{width * percentage / 100}" dur="0.5s" fill="freeze"/>
      </rect>
      <text x="#{width / 2}" y="#{height / 2 + 5}" text-anchor="middle" font-size="12" fill="#333">#{value}/#{max_val}</text>
    </svg>
    """

    # Wrap with label if present
    if gauge.label do
      ~s(<div class="gauge-container">) <>
        escape_html(gauge.label) <>
        ~s(</div>) <>
        svg_content
    else
      svg_content
    end
  end

  defp convert_by_type(%Widgets.Sparkline{} = sparkline, :sparkline, _state) do
    data = sparkline.data || []
    width = sparkline.width || 200
    height = sparkline.height || 50

    # Generate SVG sparkline
    svg_content =
      if length(data) > 1 do
        min_val = Enum.min(data)
        max_val = Enum.max(data)
        range = max_val - min_val

        # Build points for polyline
        points =
          data
          |> Enum.with_index()
          |> Enum.map_join(" ", fn {val, idx} ->
            x = idx * (width / max(length(data) - 1, 1))

            y =
              if range > 0 do
                height - (val - min_val) / range * height
              else
                height / 2
              end

            "#{x},#{y}"
          end)

        # Build area polygon if show_area
        area_polygon =
          if sparkline.show_area do
            "<polygon points=\"0,#{height} " <>
              points <> " #{width},#{height}\" fill=\"rgba(76, 175, 80, 0.2)\"/>"
          else
            ""
          end

        # Build color
        color =
          case sparkline.color do
            :cyan -> "#00BCD4"
            :green -> "#4CAF50"
            :blue -> "#2196F3"
            :red -> "#F44336"
            :yellow -> "#FFEB3B"
            _ -> "#4CAF50"
          end

        ~s(<svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">#{area_polygon}<polyline points="#{points}" fill="none" stroke="#{color}" stroke-width="2"/></svg>)
      else
        ~s(<span>No data</span>)
      end

    svg_content
  end

  defp convert_by_type(%Widgets.BarChart{} = chart, :bar_chart, _state) do
    data = chart.data || []
    width = chart.width || 300
    height = chart.height || 200

    # Generate SVG bar chart
    svg_content =
      if data != [] do
        max_val = data |> Enum.map(fn {_, v} -> v end) |> Enum.max(fn -> 0 end)

        bar_width =
          if chart.orientation == :horizontal do
            width / max(length(data), 1) - 10
          else
            width / max(length(data), 1) - 10
          end

        bars =
          if chart.orientation == :horizontal do
            # Horizontal bars
            Enum.with_index(data)
            |> Enum.map_join("\n", fn {{label, value}, idx} ->
              bar_width_px = if max_val > 0, do: value / max_val * (width - 80), else: 0
              y = idx * 30 + 10

              """
                <text x="0" y="#{y + 15}" font-size="12">#{escape_html(label)}</text>
                <rect x="70" y="#{y}" width="#{bar_width_px}" height="20" fill="#2196F3" rx="2">
                  <animate attributeName="width" from="0" to="#{bar_width_px}" dur="0.5s" fill="freeze"/>
                </rect>
                <text x="#{bar_width_px + 75}" y="#{y + 15}" font-size="12">#{value}</text>
              """
            end)
          else
            # Vertical bars
            Enum.with_index(data)
            |> Enum.map_join("\n", fn {{label, value}, idx} ->
              bar_height_px = if max_val > 0, do: value / max_val * (height - 40), else: 0
              x = idx * (width / max(length(data), 1)) + 10
              y = height - bar_height_px - 30

              """
                <rect x="#{x}" y="#{y}" width="#{bar_width}" height="#{bar_height_px}" fill="#2196F3" rx="2">
                  <animate attributeName="height" from="0" to="#{bar_height_px}" dur="0.5s" fill="freeze"/>
                  <animate attributeName="y" from="#{height - 30}" to="#{y}" dur="0.5s" fill="freeze"/>
                </rect>
                <text x="#{x + bar_width / 2}" y="#{height - 10}" text-anchor="middle" font-size="10">#{escape_html(String.slice(label, 0, 5))}</text>
              """
            end)
          end

        """
        <svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">
          #{bars}
        </svg>
        """
      else
        ~s(<span>No data</span>)
      end

    svg_content
  end

  defp convert_by_type(%Widgets.LineChart{} = chart, :line_chart, _state) do
    data = chart.data || []
    width = chart.width || 300
    height = chart.height || 200

    # Generate SVG line chart
    svg_content =
      if length(data) > 1 do
        min_val = data |> Enum.map(fn {_, v} -> v end) |> Enum.min()
        max_val = data |> Enum.map(fn {_, v} -> v end) |> Enum.max()
        range = max_val - min_val

        # Build points for polyline
        points =
          data
          |> Enum.with_index()
          |> Enum.map_join(" ", fn {{_label, val}, idx} ->
            x = idx * (width / max(length(data) - 1, 1))

            y =
              if range > 0 do
                height - 30 - (val - min_val) / range * (height - 50)
              else
                height / 2
              end

            "#{x},#{y}"
          end)

        # Build area polygon if show_area
        area_polygon =
          if chart.show_area do
            "<polygon points=\"0,#{height - 30} " <>
              points <> " #{width},#{height - 30}\" fill=\"rgba(33, 150, 243, 0.2)\"/>"
          else
            ""
          end

        # Build dots if show_dots
        dots =
          if chart.show_dots do
            data
            |> Enum.with_index()
            |> Enum.map_join("\n", fn {{_label, val}, idx} ->
              x = idx * (width / max(length(data) - 1, 1))

              y =
                if range > 0 do
                  height - 30 - (val - min_val) / range * (height - 50)
                else
                  height / 2
                end

              "<circle cx=\"#{x}\" cy=\"#{y}\" r=\"4\" fill=\"#2196F3\"/>"
            end)
          else
            ""
          end

        # Build labels
        labels =
          if length(data) <= 10 do
            data
            |> Enum.with_index()
            |> Enum.map_join("\n", fn {{label, _val}, idx} ->
              x = idx * (width / max(length(data) - 1, 1))
              escaped_label = escape_html(String.slice(label, 0, 6))

              "<text x=\"#{x}\" y=\"#{height - 5}\" text-anchor=\"middle\" font-size=\"10\">#{escaped_label}</text>"
            end)
          else
            ""
          end

        ~s(<svg width="#{width}" height="#{height}" xmlns="http://www.w3.org/2000/svg">#{area_polygon}<polyline points="#{points}" fill="none" stroke="#2196F3" stroke-width="2"/>#{dots}#{labels}</svg>)
      else
        ~s(<span>No data</span>)
      end

    svg_content
  end

  defp convert_by_type(%Widgets.Table{} = table, :table, _state) do
    data = table.data || []
    columns = table.columns || []

    # Auto-generate columns from first row if not provided
    columns =
      if columns == [] and data != [] do
        first_row = hd(data)

        first_row
        |> extract_web_keys()
        |> Enum.map(fn key ->
          %Widgets.Column{
            key: key,
            header: to_string(key) |> String.capitalize(),
            sortable: true,
            align: :left
          }
        end)
      else
        columns
      end

    # Sort data if sort_column is specified
    data =
      if table.sort_column do
        UnifiedUi.Table.Sort.sort_data(data, table.sort_column, table.sort_direction)
      else
        data
      end

    # Build CSS styles
    base_style = Style.to_css(table.style)

    # Build HTML table
    table_html =
      if columns != [] do
        # Build header row
        header_cells =
          Enum.map(columns, fn col ->
            sort_indicator =
              if table.sort_column == col.key do
                if table.sort_direction == :asc, do: " &#9650;", else: " &#9660;"
              else
                ""
              end

            sortable_class = if col.sortable, do: " sortable", else: ""

            header = escape_html(col.header || "") <> sort_indicator

            # Add phx-click binding if sortable and on_sort is present
            header_attrs =
              if col.sortable and table.on_sort do
                event_name = atom_to_event_name(table.on_sort)
                ~s( phx-click=") <> event_name <> ~s(" data-column="#{col.key}")
              else
                ""
              end

            ~s(<th class="#{align_to_css_class(col.align)}#{sortable_class}"#{header_attrs}>#{header}</th>)
          end)

        header_row = ~s(<tr>#{Enum.join(header_cells, "")}</tr>)

        # Build data rows
        data_rows =
          Enum.with_index(data)
          |> Enum.map(fn {row, idx} ->
            selected_class = if table.selected_row == idx, do: " selected", else: ""

            row_attrs =
              if table.on_row_select do
                event_name = atom_to_event_name(table.on_row_select)
                ~s( phx-click=") <> event_name <> ~s(" data-row-index="#{idx}")
              else
                ""
              end

            cells =
              Enum.map(columns, fn col ->
                value = UnifiedUi.Table.Sort.get_value(row, col.key)
                formatted = apply_web_formatter(col.formatter, value)
                escaped = escape_html(formatted)
                ~s(<td class="#{align_to_css_class(col.align)}">#{escaped}</td>)
              end)

            ~s(<tr class="#{selected_class}"#{row_attrs}>#{Enum.join(cells, "")}</tr>)
          end)

        """
        <table class="unified-table" style="#{escape_html(base_style)}">
          <thead>#{header_row}</thead>
          <tbody>#{Enum.join(data_rows, "\n")}</tbody>
        </table>
        """
      else
        ~s(<span>No columns defined</span>)
      end

    table_html
  end

  # Navigation widget converters

  defp convert_by_type(%Widgets.MenuItem{} = item, :menu_item, _state) do
    label = escape_html(item.label)

    # Build attributes list
    attrs_list = []

    # Add disabled attribute
    attrs_list = if item.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list

    # Add phx-click binding if action is present
    attrs_list =
      if item.action do
        event_name = atom_to_event_name(item.action)
        [{"phx-click", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add data attributes for metadata
    attrs_list = if item.id, do: [{"data-id", item.id} | attrs_list], else: attrs_list

    attrs_list =
      if item.shortcut, do: [{"data-shortcut", item.shortcut} | attrs_list], else: attrs_list

    attrs_list = if item.icon, do: [{"data-icon", item.icon} | attrs_list], else: attrs_list

    attrs_list =
      if item.submenu != nil, do: [{"data-has-submenu", "true"} | attrs_list], else: attrs_list

    # Build icon HTML if present
    icon_html =
      if item.icon do
        ~s(<span class="menu-icon">[#{escape_html(to_string(item.icon))}]</span>)
      else
        ""
      end

    # Build shortcut HTML if present
    shortcut_html =
      if item.shortcut do
        ~s(<span class="menu-shortcut">#{escape_html(item.shortcut)}</span>)
      else
        ""
      end

    # Build submenu indicator
    submenu_html =
      if item.submenu != nil do
        ~s(<span class="submenu-indicator">&#9654;</span>)
      else
        ""
      end

    attrs = build_attributes(attrs_list)

    ~s(<li class="menu-item"#{attrs}>#{icon_html}<span class="menu-label">#{label}</span>#{shortcut_html}#{submenu_html}</li>)
  end

  defp convert_by_type(%Widgets.Menu{} = menu, :menu, state) do
    # Build attributes list
    attrs_list = []

    # Add id if present
    attrs_list = if menu.id, do: [{"id", menu.id} | attrs_list], else: attrs_list

    # Add class based on position
    position_class = if menu.position, do: " menu-#{menu.position}", else: ""
    attrs_list = [{"class", "unified-menu#{position_class}"} | attrs_list]

    # Add style
    style = Style.to_css(menu.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list

    # Build menu title if present
    title_html =
      if menu.title do
        ~s(<div class="menu-title">#{escape_html(menu.title)}</div>)
      else
        ""
      end

    # Convert menu items
    items_html =
      Enum.map_join(menu.items || [], "\n", fn item ->
        convert_iur(item, state)
      end)

    attrs = build_attributes(attrs_list)

    ~s(<nav#{attrs}>#{title_html}<ul class="menu-items">#{items_html}</ul></nav>)
  end

  defp convert_by_type(%Widgets.ContextMenu{} = menu, :context_menu, state) do
    # Build attributes list
    attrs_list = [{"class", "unified-context-menu"}]

    # Add id if present
    attrs_list = if menu.id, do: [{"id", menu.id} | attrs_list], else: attrs_list

    # Add data attribute for trigger
    attrs_list = [{"data-trigger-on", menu.trigger_on} | attrs_list]

    # Add style
    style = Style.to_css(menu.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list

    # Convert menu items
    items_html =
      Enum.map_join(menu.items || [], "\n", fn item ->
        convert_iur(item, state)
      end)

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}><ul class="context-menu-items">#{items_html}</ul></div>)
  end

  defp convert_by_type(%Widgets.Tab{} = tab, :tab, _state) do
    label = escape_html(tab.label)

    # Build attributes list
    attrs_list = [{"data-tab-id", tab.id}]

    # Add disabled attribute
    attrs_list = if tab.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list

    # Add data attribute for closable
    attrs_list = if tab.closable, do: [{"data-closable", "true"} | attrs_list], else: attrs_list

    # Build icon HTML if present
    icon_html =
      if tab.icon do
        ~s(<span class="tab-icon">[#{escape_html(to_string(tab.icon))}]</span>)
      else
        ""
      end

    # Build close button HTML if closable
    close_html =
      if tab.closable do
        ~s(<span class="tab-close" data-close-tab="#{tab.id}">&times;</span>)
      else
        ""
      end

    disabled_class = if tab.disabled, do: " disabled", else: ""

    ~s(<button class="tab-button#{disabled_class}"#{build_attributes(attrs_list)}>#{icon_html}<span class="tab-label">#{label}</span>#{close_html}</button>)
  end

  defp convert_by_type(%Widgets.Tabs{} = tabs, :tabs, state) do
    # Build attributes list
    attrs_list = [{"class", "unified-tabs"}]

    # Add id if present
    attrs_list = if tabs.id, do: [{"id", tabs.id} | attrs_list], else: attrs_list

    # Add data attribute for active tab
    attrs_list =
      if tabs.active_tab,
        do: [{"data-active-tab", tabs.active_tab} | attrs_list],
        else: attrs_list

    # Add data attribute for position
    attrs_list =
      if tabs.position, do: [{"data-position", tabs.position} | attrs_list], else: attrs_list

    # Add phx-change binding if on_change is present
    attrs_list =
      if tabs.on_change do
        event_name = atom_to_event_name(tabs.on_change)
        [{"phx-change", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add style
    style = Style.to_css(tabs.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list

    # Build position class
    position_class = if tabs.position, do: " tabs-#{tabs.position}", else: ""

    # Convert tab headers
    tab_headers_html =
      Enum.map_join(tabs.tabs || [], "\n", fn tab ->
        convert_iur(tab, state)
      end)

    # Get active tab content
    active_content_html =
      if tabs.active_tab do
        Enum.find(tabs.tabs || [], fn tab -> tab.id == tabs.active_tab end)
        |> case do
          nil ->
            ""

          tab ->
            # Only convert content if it exists
            if tab.content do
              convert_iur(tab.content, state)
            else
              ""
            end
        end
      else
        ""
      end

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}><div class="tab-bar#{position_class}">#{tab_headers_html}</div><div class="tab-content">#{active_content_html}</div></div>)
  end

  defp convert_by_type(%Widgets.TreeNode{} = node, :tree_node, state) do
    label = escape_html(node.label)

    # Build attributes list
    attrs_list = [{"data-node-id", node.id}]

    # Add data attribute for expanded state
    attrs_list = [{"data-expanded", node.expanded} | attrs_list]

    # Add data attribute for selectable
    attrs_list = [{"data-selectable", node.selectable} | attrs_list]

    # Build icon HTML if present
    icon_html =
      if node.icon do
        icon_to_use =
          if node.expanded and node.icon_expanded do
            node.icon_expanded
          else
            node.icon
          end

        ~s(<span class="tree-icon">[#{escape_html(to_string(icon_to_use))}]</span>)
      else
        ""
      end

    # Build expand/collapse button if has children
    toggle_html =
      if node.children != nil do
        if node.expanded do
          ~s(<span class="tree-toggle tree-toggle-expanded" data-toggle="#{node.id}">[-]</span>)
        else
          ~s(<span class="tree-toggle tree-toggle-collapsed" data-toggle="#{node.id}">[+]</span>)
        end
      else
        ~s(<span class="tree-toggle-placeholder"></span>)
      end

    # Convert children if expanded
    children_html =
      if node.expanded and node.children != nil do
        Enum.map_join(node.children, "\n", fn child ->
          convert_iur(child, state)
        end)
      else
        ""
      end

    children_container =
      if children_html != "" do
        ~s(<ul class="tree-children">#{children_html}</ul>)
      else
        ""
      end

    ~s(<li class="tree-node"#{build_attributes(attrs_list)}>#{toggle_html}#{icon_html}<span class="tree-label">#{label}</span>#{children_container}</li>)
  end

  defp convert_by_type(%Widgets.TreeView{} = tree, :tree_view, state) do
    # Build attributes list
    attrs_list = [{"class", "unified-tree-view"}]

    # Add id if present
    attrs_list = if tree.id, do: [{"id", tree.id} | attrs_list], else: attrs_list

    # Add data attribute for selected node
    attrs_list =
      if tree.selected_node,
        do: [{"data-selected-node", tree.selected_node} | attrs_list],
        else: attrs_list

    # Add phx-click binding if on_select is present
    attrs_list =
      if tree.on_select do
        event_name = atom_to_event_name(tree.on_select)
        [{"phx-click", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add phx-click binding for toggle if on_toggle is present
    attrs_list =
      if tree.on_toggle do
        event_name = atom_to_event_name(tree.on_toggle)
        [{"data-toggle-event", event_name} | attrs_list]
      else
        attrs_list
      end

    # Add style
    style = Style.to_css(tree.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list

    # Convert root nodes
    root_nodes_html =
      Enum.map_join(tree.root_nodes || [], "\n", fn node ->
        convert_iur(node, state)
      end)

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}><ul class="tree-root">#{root_nodes_html}</ul></div>)
  end

  # Dialog and feedback converters

  defp convert_by_type(%Widgets.DialogButton{} = button, :dialog_button, _state) do
    attrs_list = [{"class", "dialog-button dialog-role-#{button.role}"}]
    attrs_list = if button.id, do: [{"id", button.id} | attrs_list], else: attrs_list

    attrs_list =
      if button.action do
        event_name = atom_to_event_name(button.action)
        [{"phx-click", event_name} | attrs_list]
      else
        attrs_list
      end

    attrs_list = if button.disabled, do: [{"disabled", "true"} | attrs_list], else: attrs_list

    style = Style.to_css(button.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list
    attrs = build_attributes(attrs_list)

    ~s(<button#{attrs}>#{escape_html(button.label || "")}</button>)
  end

  defp convert_by_type(%Widgets.Dialog{} = dialog, :dialog, state) do
    attrs_list = [{"class", "unified-dialog"}]
    attrs_list = if dialog.id, do: [{"id", dialog.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-modal", dialog.modal} | attrs_list]
    attrs_list = [{"data-closable", dialog.closable} | attrs_list]
    attrs_list = [{"data-blocks-background", dialog.modal == true} | attrs_list]

    attrs_list =
      if dialog.on_close do
        event_name = atom_to_event_name(dialog.on_close)
        [{"data-close-event", event_name} | attrs_list]
      else
        attrs_list
      end

    attrs_list =
      if dialog.width, do: [{"data-width", dialog.width} | attrs_list], else: attrs_list

    attrs_list =
      if dialog.height, do: [{"data-height", dialog.height} | attrs_list], else: attrs_list

    style = Style.to_css(dialog.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list

    content_html =
      case dialog.content do
        nil ->
          ""

        content when is_list(content) ->
          Enum.map_join(content, "\n", fn item ->
            if is_binary(item), do: escape_html(item), else: convert_iur(item, state)
          end)

        content ->
          if is_binary(content), do: escape_html(content), else: convert_iur(content, state)
      end

    buttons_html =
      dialog.buttons
      |> List.wrap()
      |> Enum.map_join("\n", &convert_iur(&1, state))

    attrs = build_attributes(attrs_list)

    ~s(<div class="unified-dialog-backdrop"><div#{attrs}><header class="dialog-header">#{escape_html(dialog.title || "")}</header><section class="dialog-content">#{content_html}</section><footer class="dialog-actions">#{buttons_html}</footer></div></div>)
  end

  defp convert_by_type(%Widgets.AlertDialog{} = alert, :alert_dialog, _state) do
    attrs_list = [{"class", "unified-alert-dialog alert-#{alert.severity}"}]
    attrs_list = if alert.id, do: [{"id", alert.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-modal", alert.modal} | attrs_list]
    attrs_list = [{"data-blocks-background", alert.modal == true} | attrs_list]

    attrs_list =
      if alert.on_confirm do
        event_name = atom_to_event_name(alert.on_confirm)
        [{"data-confirm-event", event_name} | attrs_list]
      else
        attrs_list
      end

    attrs_list =
      if alert.on_cancel do
        event_name = atom_to_event_name(alert.on_cancel)
        [{"data-cancel-event", event_name} | attrs_list]
      else
        attrs_list
      end

    style = Style.to_css(alert.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list
    attrs = build_attributes(attrs_list)

    ~s(<div class="unified-dialog-backdrop"><div#{attrs}><header class="alert-title">#{escape_html(alert.title || "")}</header><p class="alert-message">#{escape_html(alert.message || "")}</p></div></div>)
  end

  defp convert_by_type(%Widgets.Toast{} = toast, :toast, _state) do
    dismiss_at = toast_dismiss_at(toast.duration)

    attrs_list = [{"class", "unified-toast toast-#{toast.severity}"}]
    attrs_list = if toast.id, do: [{"id", toast.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-duration", toast.duration} | attrs_list]
    attrs_list = [{"data-auto-dismiss", not is_nil(dismiss_at)} | attrs_list]

    attrs_list =
      if dismiss_at, do: [{"data-dismiss-at", dismiss_at} | attrs_list], else: attrs_list

    attrs_list =
      if toast.on_dismiss do
        event_name = atom_to_event_name(toast.on_dismiss)
        [{"data-dismiss-event", event_name} | attrs_list]
      else
        attrs_list
      end

    style = Style.to_css(toast.style)
    attrs_list = if style, do: [{"style", style} | attrs_list], else: attrs_list
    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{escape_html(toast.message || "")}</div>)
  end

  # Container widget converters

  defp convert_by_type(%Viewport{} = viewport, :viewport, state) do
    content_html =
      case viewport.content do
        nil -> ""
        content -> convert_iur(content, state)
      end

    css_parts = ["overflow: auto"]
    css_parts = maybe_add_width_css(css_parts, viewport.width)
    css_parts = maybe_add_height_css(css_parts, viewport.height)

    css_parts =
      if viewport.border in [true, :solid, :dashed, :double] do
        border_style =
          case viewport.border do
            :dashed -> "1px dashed #888"
            :double -> "3px double #888"
            _ -> "1px solid #888"
          end

        ["border: #{border_style}" | css_parts]
      else
        css_parts
      end

    style = Style.to_css(viewport.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if viewport.id, do: [{"id", viewport.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-scroll-x", viewport.scroll_x} | attrs_list]
    attrs_list = [{"data-scroll-y", viewport.scroll_y} | attrs_list]

    attrs_list =
      if viewport.on_scroll do
        [{"data-scroll-event", atom_to_event_name(viewport.on_scroll)} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{content_html}</div>)
  end

  defp convert_by_type(%SplitPane{} = split_pane, :split_pane, state) do
    panes_html =
      split_pane.panes
      |> List.wrap()
      |> Enum.map_join(&convert_iur(&1, state))

    direction = if split_pane.orientation == :vertical, do: "column", else: "row"
    css_parts = ["display: flex", "flex-direction: #{direction}", "width: 100%"]
    style = Style.to_css(split_pane.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if split_pane.id, do: [{"id", split_pane.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-initial-split", split_pane.initial_split} | attrs_list]
    attrs_list = [{"data-min-size", split_pane.min_size} | attrs_list]

    attrs_list =
      if split_pane.on_resize_change do
        [{"data-resize-event", atom_to_event_name(split_pane.on_resize_change)} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{panes_html}</div>)
  end

  defp convert_by_type(%Canvas{} = canvas, :canvas, _state) do
    css_parts = ["display: block"]
    css_parts = maybe_add_width_css(css_parts, canvas.width)
    css_parts = maybe_add_height_css(css_parts, canvas.height)
    style = Style.to_css(canvas.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if canvas.id, do: [{"id", canvas.id} | attrs_list], else: attrs_list
    attrs_list = if canvas.width, do: [{"width", canvas.width} | attrs_list], else: attrs_list
    attrs_list = if canvas.height, do: [{"height", canvas.height} | attrs_list], else: attrs_list

    attrs_list =
      if canvas.on_click do
        [{"data-click-event", atom_to_event_name(canvas.on_click)} | attrs_list]
      else
        attrs_list
      end

    attrs_list =
      if canvas.on_hover do
        [{"data-hover-event", atom_to_event_name(canvas.on_hover)} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<canvas#{attrs}></canvas>)
  end

  defp convert_by_type(%CommandPalette{} = palette, :command_palette, _state) do
    commands_html =
      palette.commands
      |> List.wrap()
      |> Enum.map_join(&command_palette_command_html/1)

    css_parts = ["display: flex", "flex-direction: column", "gap: 8px", "width: 100%"]
    style = Style.to_css(palette.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if palette.id, do: [{"id", palette.id} | attrs_list], else: attrs_list

    attrs_list =
      if palette.trigger_shortcut,
        do: [{"data-trigger-shortcut", palette.trigger_shortcut} | attrs_list],
        else: attrs_list

    attrs_list =
      if palette.on_select do
        [{"data-select-event", atom_to_event_name(palette.on_select)} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)
    placeholder = escape_html(palette.placeholder || "Type a command...")

    ~s(<div#{attrs}><input type="text" placeholder="#{placeholder}" /><ul>#{commands_html}</ul></div>)
  end

  defp convert_by_type(%LogViewer{} = log_viewer, :log_viewer, _state) do
    css_parts = ["display: block", "overflow: auto", "white-space: pre-wrap"]
    style = Style.to_css(log_viewer.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if log_viewer.id, do: [{"id", log_viewer.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-lines", log_viewer.lines} | attrs_list]
    attrs_list = [{"data-auto-scroll", log_viewer.auto_scroll} | attrs_list]
    attrs_list = [{"data-filter", log_viewer.filter} | attrs_list]
    attrs_list = [{"data-refresh-interval", log_viewer.refresh_interval} | attrs_list]
    attrs_list = [{"data-auto-refresh", log_viewer.refresh_interval > 0} | attrs_list]
    attrs_list = [{"data-source", serialize_option_value(log_viewer.source)} | attrs_list]

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>Log Viewer</div>)
  end

  defp convert_by_type(%StreamWidget{} = stream_widget, :stream_widget, _state) do
    css_parts = ["display: block"]
    style = Style.to_css(stream_widget.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]

    attrs_list =
      if stream_widget.id, do: [{"id", stream_widget.id} | attrs_list], else: attrs_list

    attrs_list = [{"data-buffer-size", stream_widget.buffer_size} | attrs_list]
    attrs_list = [{"data-refresh-interval", stream_widget.refresh_interval} | attrs_list]
    attrs_list = [{"data-auto-refresh", stream_widget.refresh_interval > 0} | attrs_list]
    attrs_list = [{"data-producer", serialize_option_value(stream_widget.producer)} | attrs_list]

    attrs_list =
      if stream_widget.on_item do
        [{"data-on-item", atom_to_event_name(stream_widget.on_item)} | attrs_list]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>Stream Widget</div>)
  end

  defp convert_by_type(%ProcessMonitor{} = process_monitor, :process_monitor, _state) do
    css_parts = ["display: block"]
    style = Style.to_css(process_monitor.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]

    attrs_list =
      if process_monitor.id do
        [{"id", process_monitor.id} | attrs_list]
      else
        attrs_list
      end

    attrs_list = [{"data-node", process_monitor.node || node()} | attrs_list]
    attrs_list = [{"data-sort-by", process_monitor.sort_by} | attrs_list]
    attrs_list = [{"data-refresh-interval", process_monitor.refresh_interval} | attrs_list]
    attrs_list = [{"data-auto-refresh", process_monitor.refresh_interval > 0} | attrs_list]

    attrs_list =
      if process_monitor.on_process_select do
        [
          {"data-select-event", atom_to_event_name(process_monitor.on_process_select)}
          | attrs_list
        ]
      else
        attrs_list
      end

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>Process Monitor</div>)
  end

  # Layout converters

  defp convert_by_type(%Grid{} = grid, :grid, state) do
    children_html = convert_children(grid.children, state)
    columns = normalize_grid_tracks(grid.columns)
    rows = normalize_grid_tracks(grid.rows)

    css_parts = ["display: grid"]
    css_parts = maybe_add_grid_columns_css(css_parts, columns)
    css_parts = maybe_add_grid_rows_css(css_parts, rows)
    css_parts = maybe_add_spacing_css(css_parts, grid.gap)

    style = Style.to_css(grid.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if grid.id, do: [{"id", grid.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-columns", Enum.join(columns, ",")} | attrs_list]
    attrs_list = [{"data-rows", Enum.join(rows, ",")} | attrs_list]
    attrs_list = [{"data-gap", grid.gap} | attrs_list]

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{children_html}</div>)
  end

  defp convert_by_type(%Stack{} = stack, :stack, state) do
    children = convert_children_list(stack.children, state)
    active_index = normalize_active_index(stack.active_index, length(children))
    active_child_html = Enum.at(children, active_index, "")

    css_parts = ["display: block", "position: relative"]
    css_parts = maybe_add_transition_css(css_parts, stack.transition)

    style = Style.to_css(stack.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if stack.id, do: [{"id", stack.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-active-index", active_index} | attrs_list]
    attrs_list = [{"data-transition", stack.transition} | attrs_list]

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{active_child_html}</div>)
  end

  defp convert_by_type(%ZBox{} = zbox, :zbox, state) do
    children_html = convert_children_list(zbox.children, state)
    positions = normalize_zbox_positions(zbox.positions)

    layered_children =
      children_html
      |> Enum.with_index()
      |> Enum.map_join(fn {child_html, index} ->
        source_child = Enum.at(zbox.children, index)
        child_id = child_element_id(source_child)
        position = zbox_child_position(positions, index, child_id)
        position_css = zbox_position_css(position)
        child_attrs = build_attributes([{"style", position_css}, {"data-index", index}])
        ~s(<div#{child_attrs}>#{child_html}</div>)
      end)

    css_parts = ["position: relative", "display: block"]
    style = Style.to_css(zbox.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")

    attrs_list = [{"style", css}]
    attrs_list = if zbox.id, do: [{"id", zbox.id} | attrs_list], else: attrs_list
    attrs_list = [{"data-positioned-children", length(children_html)} | attrs_list]

    attrs = build_attributes(attrs_list)

    ~s(<div#{attrs}>#{layered_children}</div>)
  end

  defp convert_by_type(%Layouts.VBox{} = vbox, :vbox, state) do
    children_html = convert_children_list(vbox.children, state)
    render_root_layout_html(vbox, children_html)
  end

  defp convert_by_type(%Layouts.HBox{} = hbox, :hbox, state) do
    children_html = convert_children_list(hbox.children, state)
    render_root_layout_html(hbox, children_html)
  end

  # Fallback for unknown types
  defp convert_by_type(_element, _type, _state) do
    # Return empty span for unknown element types
    "<span></span>"
  end

  # Helper functions

  defp convert_children(children, state) when is_list(children) do
    children
    |> Enum.map(fn child -> convert_iur(child, state) end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.join()
  end

  defp convert_children(_, _state), do: ""

  defp convert_children_list(children, state) when is_list(children) do
    children
    |> Enum.map(fn child -> convert_iur(child, state) end)
    |> Enum.reject(&(&1 == ""))
  end

  defp convert_children_list(_children, _state), do: []

  defp command_palette_command_html(command) do
    command = command_palette_command_map(command)
    id = Map.get(command, :id)
    label = escape_html(Map.get(command, :label) || to_string(id || "command"))
    description = Map.get(command, :description)
    shortcut = Map.get(command, :shortcut)

    attrs =
      [
        {"data-command-id", id},
        {"data-command-label", Map.get(command, :label)},
        {"data-command-shortcut", shortcut},
        {"data-command-disabled", Map.get(command, :disabled) == true}
      ]
      |> build_attributes()

    description_html =
      if is_binary(description) and description != "" do
        ~s(<small>#{escape_html(description)}</small>)
      else
        ""
      end

    shortcut_html =
      if is_binary(shortcut) and shortcut != "" do
        ~s(<kbd>#{escape_html(shortcut)}</kbd>)
      else
        ""
      end

    ~s(<li#{attrs}>#{label}#{shortcut_html}#{description_html}</li>)
  end

  defp command_palette_command_map(%Command{} = command) do
    %{
      id: command.id,
      label: command.label,
      description: command.description,
      shortcut: command.shortcut,
      keywords: command.keywords,
      disabled: command.disabled
    }
  end

  defp command_palette_command_map(command) when is_map(command) do
    disabled =
      cond do
        Map.has_key?(command, :disabled) -> Map.get(command, :disabled) == true
        Map.has_key?(command, "disabled") -> Map.get(command, "disabled") == true
        true -> false
      end

    %{
      id: Map.get(command, :id) || Map.get(command, "id"),
      label: Map.get(command, :label) || Map.get(command, "label"),
      description: Map.get(command, :description) || Map.get(command, "description"),
      shortcut: Map.get(command, :shortcut) || Map.get(command, "shortcut"),
      keywords:
        (Map.get(command, :keywords) || Map.get(command, "keywords") || []) |> List.wrap(),
      disabled: disabled
    }
  end

  defp command_palette_command_map({id, label}) when is_atom(id) and is_binary(label) do
    %{id: id, label: label, description: nil, shortcut: nil, keywords: [], disabled: false}
  end

  defp command_palette_command_map(other) do
    %{
      id: other,
      label: inspect(other),
      description: nil,
      shortcut: nil,
      keywords: [],
      disabled: false
    }
  end

  defp maybe_add_width_css(parts, nil), do: parts
  defp maybe_add_width_css(parts, width) when is_integer(width), do: ["width: #{width}px" | parts]

  defp maybe_add_height_css(parts, nil), do: parts

  defp maybe_add_height_css(parts, height) when is_integer(height),
    do: ["height: #{height}px" | parts]

  defp normalize_grid_tracks(nil), do: []
  defp normalize_grid_tracks([]), do: []

  defp normalize_grid_tracks(tracks) when is_list(tracks) do
    Enum.map(tracks, &normalize_grid_track/1)
  end

  defp normalize_grid_tracks(track), do: [normalize_grid_track(track)]

  defp normalize_grid_track(track) when is_integer(track) and track > 0,
    do: "#{track}fr"

  defp normalize_grid_track(track) when is_integer(track), do: "#{track}"
  defp normalize_grid_track(:auto), do: "auto"
  defp normalize_grid_track(track) when is_binary(track), do: track
  defp normalize_grid_track(track), do: inspect(track)

  defp maybe_add_grid_columns_css(css_parts, []), do: css_parts

  defp maybe_add_grid_columns_css(css_parts, columns) do
    ["grid-template-columns: #{Enum.join(columns, " ")}" | css_parts]
  end

  defp maybe_add_grid_rows_css(css_parts, []), do: css_parts

  defp maybe_add_grid_rows_css(css_parts, rows) do
    ["grid-template-rows: #{Enum.join(rows, " ")}" | css_parts]
  end

  defp normalize_active_index(index, child_count)
       when is_integer(index) and is_integer(child_count) and child_count > 0 do
    index
    |> max(0)
    |> min(child_count - 1)
  end

  defp normalize_active_index(_index, _child_count), do: 0

  defp maybe_add_transition_css(css_parts, nil), do: css_parts

  defp maybe_add_transition_css(css_parts, :fade),
    do: ["transition: opacity 150ms ease" | css_parts]

  defp maybe_add_transition_css(css_parts, :slide),
    do: ["transition: transform 150ms ease" | css_parts]

  defp maybe_add_transition_css(css_parts, transition) when is_atom(transition),
    do: ["transition: #{transition}" | css_parts]

  defp maybe_add_transition_css(css_parts, transition) when is_binary(transition),
    do: ["transition: #{transition}" | css_parts]

  defp maybe_add_transition_css(css_parts, _transition), do: css_parts

  defp normalize_zbox_positions(nil), do: %{}
  defp normalize_zbox_positions(positions) when is_map(positions), do: positions

  defp normalize_zbox_positions(positions) when is_list(positions) do
    if Keyword.keyword?(positions) do
      Enum.into(positions, %{})
    else
      positions
      |> Enum.with_index()
      |> Enum.into(%{}, fn {position, index} -> {index, position} end)
    end
  end

  defp normalize_zbox_positions(_positions), do: %{}

  defp zbox_child_position(positions, index, child_id) do
    Map.get(positions, index) ||
      Map.get(positions, Integer.to_string(index)) ||
      if(is_atom(child_id), do: Map.get(positions, child_id), else: nil) ||
      if(is_atom(child_id), do: Map.get(positions, Atom.to_string(child_id)), else: nil) ||
      %{}
  end

  defp zbox_position_css(position) when is_map(position) do
    x = map_get_integer(position, :x, 0)
    y = map_get_integer(position, :y, 0)
    z = map_get_integer(position, :z, map_get_integer(position, :z_index, 0))
    width = map_get_integer(position, :width, nil)
    height = map_get_integer(position, :height, nil)

    css_parts = ["position: absolute", "left: #{x}px", "top: #{y}px", "z-index: #{z}"]

    css_parts =
      if is_integer(width), do: ["width: #{width}px" | css_parts], else: css_parts

    css_parts =
      if is_integer(height), do: ["height: #{height}px" | css_parts], else: css_parts

    Enum.reverse(css_parts) |> Enum.join("; ")
  end

  defp zbox_position_css(_position), do: "position: absolute; left: 0px; top: 0px; z-index: 0"

  defp child_element_id(nil), do: nil

  defp child_element_id(child) do
    case Element.metadata(child) do
      %{id: id} -> id
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp map_get_integer(map, key, default) when is_map(map) do
    value = Map.get(map, key) || Map.get(map, Atom.to_string(key))
    if is_integer(value), do: value, else: default
  end

  defp form_field_name(nil), do: "field"
  defp form_field_name(name) when is_atom(name), do: Atom.to_string(name)
  defp form_field_name(name) when is_binary(name), do: name
  defp form_field_name(name), do: serialize_option_value(name)

  defp normalize_form_option(%Widgets.PickListOption{} = option) do
    value = option.value
    label = option.label || serialize_option_value(value)
    {value, label}
  end

  defp normalize_form_option({value, label}), do: {value, serialize_option_value(label)}

  defp normalize_form_option(%{value: value, label: label}) do
    {value, serialize_option_value(label)}
  end

  defp normalize_form_option(option) when is_map(option) do
    value = Map.get(option, :value) || Map.get(option, "value")
    label = Map.get(option, :label) || Map.get(option, "label") || serialize_option_value(value)
    {value, serialize_option_value(label)}
  end

  defp normalize_form_option(option) when is_list(option) do
    option
    |> Enum.into(%{})
    |> normalize_form_option()
  end

  defp normalize_form_option(option), do: {option, serialize_option_value(option)}

  defp serialize_option_value(nil), do: ""
  defp serialize_option_value(value) when is_binary(value), do: value
  defp serialize_option_value(value) when is_atom(value), do: Atom.to_string(value)
  defp serialize_option_value(value) when is_integer(value), do: Integer.to_string(value)
  defp serialize_option_value(value) when is_float(value), do: Float.to_string(value)
  defp serialize_option_value(value), do: inspect(value)

  # Build HTML attributes string
  defp build_attributes(attrs_list) do
    attrs_list
    |> Enum.reject(fn {_, value} -> is_nil(value) or value == "" end)
    |> Enum.map_join(fn {name, value} -> " #{name}=\"#{escape_html(value)}\"" end)
  end

  # Spacing in CSS (using gap property for flexbox)
  defp maybe_add_spacing_css(css_parts, nil), do: css_parts

  defp maybe_add_spacing_css(css_parts, spacing) when is_integer(spacing),
    do: ["gap: #{spacing}px" | css_parts]

  # Padding in CSS
  defp maybe_add_padding_css(css_parts, nil), do: css_parts

  defp maybe_add_padding_css(css_parts, padding) when is_integer(padding),
    do: ["padding: #{padding}px" | css_parts]

  # Alignment mapping to CSS
  # For flexbox, align-items controls cross-axis alignment
  defp maybe_add_align_items_css(css_parts, nil, _direction), do: css_parts

  defp maybe_add_align_items_css(css_parts, :start, :column),
    do: ["align-items: flex-start" | css_parts]

  defp maybe_add_align_items_css(css_parts, :center, _direction),
    do: ["align-items: center" | css_parts]

  defp maybe_add_align_items_css(css_parts, :end, :column),
    do: ["align-items: flex-end" | css_parts]

  defp maybe_add_align_items_css(css_parts, :start, :row),
    do: ["align-items: center" | css_parts]

  defp maybe_add_align_items_css(css_parts, :end, :row),
    do: ["align-items: stretch" | css_parts]

  defp maybe_add_align_items_css(css_parts, align, _direction),
    do: ["align-items: #{align}" | css_parts]

  # Justification mapping to CSS
  # For flexbox, justify-content controls main-axis alignment
  defp maybe_add_justify_content_css(css_parts, nil, _direction), do: css_parts

  defp maybe_add_justify_content_css(css_parts, :start, _direction),
    do: ["justify-content: flex-start" | css_parts]

  defp maybe_add_justify_content_css(css_parts, :center, _direction),
    do: ["justify-content: center" | css_parts]

  defp maybe_add_justify_content_css(css_parts, :end, _direction),
    do: ["justify-content: flex-end" | css_parts]

  defp maybe_add_justify_content_css(css_parts, justify, _direction),
    do: ["justify-content: #{justify}" | css_parts]

  # Convert Elixir atom to Phoenix LiveView event name
  defp atom_to_event_name(atom) when is_atom(atom) do
    atom |> Atom.to_string() |> String.replace("_", "-")
  end

  # Handle tuple event handlers like {:submit, %{form: :login}}
  defp atom_to_event_name({event_name, _payload}) when is_atom(event_name) do
    event_name |> Atom.to_string() |> String.replace("_", "-")
  end

  # Handle MFA tuples {Module, :function, args}
  defp atom_to_event_name({_module, _function, _args}) do
    "generic-event"
  end

  # Fallback for other types
  defp atom_to_event_name(other) when is_binary(other), do: other
  defp atom_to_event_name(_other), do: "event"

  # Convert input type atom to HTML type string
  defp input_type_to_string(nil), do: "text"
  defp input_type_to_string(:text), do: "text"
  defp input_type_to_string(:password), do: "password"
  defp input_type_to_string(:email), do: "email"
  defp input_type_to_string(:number), do: "number"
  defp input_type_to_string(:tel), do: "tel"
  defp input_type_to_string(:url), do: "url"
  defp input_type_to_string(:search), do: "search"
  defp input_type_to_string(_), do: "text"

  # Basic HTML escaping
  defp escape_html(nil), do: ""

  defp escape_html(value) when is_binary(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  defp escape_html(value), do: value |> to_string() |> escape_html()

  # Web table helpers

  defp extract_web_keys(row) when is_map(row) do
    row |> Map.keys() |> Enum.sort()
  end

  defp extract_web_keys(row) when is_list(row) do
    Keyword.keys(row)
  end

  defp apply_web_formatter(nil, value), do: format_web_value(value)
  defp apply_web_formatter(formatter, value) when is_function(formatter, 1), do: formatter.(value)
  defp apply_web_formatter(_formatter, value), do: format_web_value(value)

  defp format_web_value(nil), do: ""
  defp format_web_value(value) when is_binary(value), do: value
  defp format_web_value(value) when is_atom(value), do: to_string(value)
  defp format_web_value(value), do: inspect(value, limit: 50)

  defp align_to_css_class(:left), do: "align-left"
  defp align_to_css_class(:right), do: "align-right"
  defp align_to_css_class(:center), do: "align-center"

  defp toast_dismiss_at(duration) when is_integer(duration) and duration > 0 do
    System.monotonic_time(:millisecond) + duration
  end

  defp toast_dismiss_at(_duration), do: nil

  defp build_updated_root(
         iur_tree,
         previous_iur,
         previous_rendered_children,
         previous_render_cache,
         renderer_state,
         config_changed,
         format
       ) do
    previous_root_render_cache =
      normalize_root_render_cache(previous_render_cache, previous_rendered_children)

    cond do
      config_changed ->
        full_render_with_cache(iur_tree, renderer_state, format, :config_changed)

      previous_iur == :__missing__ ->
        full_render_with_cache(iur_tree, renderer_state, format, :missing_previous_iur)

      true ->
        case patch_root_layout_children(
               iur_tree,
               previous_iur,
               previous_root_render_cache,
               renderer_state,
               format
             ) do
          {:ok, patched_root, patched_children_cache, reused_children, re_rendered_children} ->
            root_layout_children_rendered = render_cache_html_list(patched_children_cache)

            {patched_root,
             %{
               applied: true,
               strategy: :root_layout_children,
               reused_children: reused_children,
               re_rendered_children: re_rendered_children
             }, root_layout_children_rendered, patched_children_cache}

          :error ->
            full_render_with_cache(iur_tree, renderer_state, format, :full_render_fallback)
        end
    end
  end

  defp full_render_with_cache(iur_tree, renderer_state, format, reason) do
    root_layout_children_render_cache =
      root_layout_children_render_cache(iur_tree, renderer_state)

    root_layout_children_rendered = render_cache_html_list(root_layout_children_render_cache)

    {render_output(iur_tree, renderer_state, format), fallback_incremental_patch(reason),
     root_layout_children_rendered, root_layout_children_render_cache}
  end

  defp fallback_incremental_patch(reason) when is_atom(reason) do
    %{
      applied: false,
      strategy: nil,
      reused_children: 0,
      re_rendered_children: 0,
      reason: reason
    }
  end

  defp patch_root_layout_children(
         %module{} = iur_tree,
         %module{} = previous_iur,
         rendered_children_cache,
         %State{} = state,
         format
       )
       when module in [Layouts.VBox, Layouts.HBox] do
    with true <- layout_signature(iur_tree) == layout_signature(previous_iur),
         true <- is_list(rendered_children_cache),
         true <-
           same_child_count?(iur_tree.children, previous_iur.children, rendered_children_cache),
         {:ok, patched_children, reused_children, re_rendered_children} <-
           patch_children(
             iur_tree.children,
             previous_iur.children,
             rendered_children_cache,
             state
           ) do
      patched_root =
        iur_tree
        |> render_root_layout_html(render_cache_html_list(patched_children))
        |> format_root_output(format)

      {:ok, patched_root, patched_children, reused_children, re_rendered_children}
    else
      _ -> :error
    end
  end

  defp patch_root_layout_children(_, _, _, _, _), do: :error

  defp layout_signature(%_{} = layout) do
    layout
    |> Map.from_struct()
    |> Map.drop([:children])
  end

  defp same_child_count?(new_children, old_children, rendered_children)
       when is_list(new_children) and is_list(old_children) and is_list(rendered_children) do
    length(new_children) == length(old_children) and
      length(old_children) == length(rendered_children)
  end

  defp same_child_count?(_, _, _), do: false

  defp patch_children(new_children, old_children, rendered_children, state) do
    patch_result =
      new_children
      |> Enum.zip(old_children)
      |> Enum.zip(rendered_children)
      |> Enum.reduce_while({[], 0, 0}, fn {{new_child, old_child}, rendered_child},
                                          {children_acc, reused_acc, rerendered_acc} ->
        case patch_child(new_child, old_child, rendered_child, state) do
          {:ok, patched_child, reused_delta, rerendered_delta} ->
            {:cont,
             {[
                patched_child
                | children_acc
              ], reused_acc + reused_delta, rerendered_acc + rerendered_delta}}

          :error ->
            {:halt, :error}
        end
      end)

    case patch_result do
      :error ->
        :error

      {patched_children, reused_children, re_rendered_children} ->
        {:ok, Enum.reverse(patched_children), reused_children, re_rendered_children}
    end
  end

  defp patch_child(new_child, old_child, rendered_child, _state) when new_child == old_child do
    {:ok, rendered_child, 1, 0}
  end

  defp patch_child(new_child, old_child, rendered_child, state) do
    case patch_nested_layout_child(new_child, old_child, rendered_child, state) do
      {:ok, patched_child, reused_children, re_rendered_children} ->
        {:ok, patched_child, reused_children, re_rendered_children}

      :error ->
        patched_child = build_render_cache(new_child, state)

        if render_cache_html(patched_child) == "" do
          :error
        else
          {:ok, patched_child, 0, 1}
        end
    end
  end

  defp patch_nested_layout_child(
         %module{} = new_layout,
         %module{} = old_layout,
         rendered_child,
         state
       )
       when module in [Layouts.VBox, Layouts.HBox] do
    with true <- layout_signature(new_layout) == layout_signature(old_layout),
         {:ok, rendered_children} <- extract_layout_render_cache_children(rendered_child, module),
         true <- same_child_count?(new_layout.children, old_layout.children, rendered_children),
         {:ok, patched_children, reused_children, re_rendered_children} <-
           patch_children(new_layout.children, old_layout.children, rendered_children, state) do
      patched_html =
        new_layout |> render_root_layout_html(render_cache_html_list(patched_children))

      {:ok, layout_render_cache(module, patched_html, patched_children), reused_children,
       re_rendered_children}
    else
      _ -> :error
    end
  end

  defp patch_nested_layout_child(_, _, _, _), do: :error

  defp normalize_root_render_cache(previous_render_cache, _previous_rendered_children)
       when is_list(previous_render_cache) do
    Enum.map(previous_render_cache, fn
      %{kind: :layout} = render_cache -> render_cache
      %{kind: :leaf} = render_cache -> render_cache
      render_cache -> render_cache |> render_cache_html() |> leaf_render_cache()
    end)
  end

  defp normalize_root_render_cache(:__missing__, previous_rendered_children)
       when is_list(previous_rendered_children) do
    Enum.map(previous_rendered_children, &leaf_render_cache/1)
  end

  defp normalize_root_render_cache(_, _), do: nil

  defp extract_layout_render_cache_children(
         %{kind: :layout, layout_module: module, children: children},
         module
       )
       when is_list(children) do
    {:ok, children}
  end

  defp extract_layout_render_cache_children(_, _), do: :error

  defp build_render_cache(%module{} = layout, state)
       when module in [Layouts.VBox, Layouts.HBox] do
    children = build_children_render_cache(layout.children, state)
    html = layout |> render_root_layout_html(render_cache_html_list(children))
    layout_render_cache(module, html, children)
  end

  defp build_render_cache(iur_element, state) do
    iur_element
    |> convert_iur(state)
    |> leaf_render_cache()
  end

  defp build_children_render_cache(children, state) when is_list(children) do
    children
    |> Enum.map(&build_render_cache(&1, state))
    |> Enum.reject(&(render_cache_html(&1) == ""))
  end

  defp build_children_render_cache(_, _), do: []

  defp layout_render_cache(module, html, children) do
    %{kind: :layout, layout_module: module, html: html, children: children}
  end

  defp leaf_render_cache(html) when is_binary(html), do: %{kind: :leaf, html: html}
  defp leaf_render_cache(_), do: %{kind: :leaf, html: ""}

  defp render_cache_html(%{html: html}) when is_binary(html), do: html
  defp render_cache_html(html) when is_binary(html), do: html
  defp render_cache_html(_), do: ""

  defp render_cache_html_list(cache_entries) when is_list(cache_entries) do
    Enum.map(cache_entries, &render_cache_html/1)
  end

  defp render_cache_html_list(_), do: nil

  defp root_layout_children_render_cache(%module{} = iur_tree, %State{} = state)
       when module in [Layouts.VBox, Layouts.HBox] do
    build_children_render_cache(iur_tree.children, state)
  end

  defp root_layout_children_render_cache(_, _), do: nil

  defp render_root_layout_html(%Layouts.VBox{} = vbox, children_html)
       when is_list(children_html) do
    css_parts = ["display: flex", "flex-direction: column"]
    css_parts = maybe_add_spacing_css(css_parts, vbox.spacing)
    css_parts = maybe_add_padding_css(css_parts, vbox.padding)
    css_parts = maybe_add_align_items_css(css_parts, vbox.align_items, :column)
    css_parts = maybe_add_justify_content_css(css_parts, vbox.justify_content, :column)

    style = Style.to_css(vbox.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")
    attrs = build_attributes([{"style", css}])

    ~s(<div#{attrs}>#{Enum.join(children_html)}</div>)
  end

  defp render_root_layout_html(%Layouts.HBox{} = hbox, children_html)
       when is_list(children_html) do
    css_parts = ["display: flex", "flex-direction: row"]
    css_parts = maybe_add_spacing_css(css_parts, hbox.spacing)
    css_parts = maybe_add_padding_css(css_parts, hbox.padding)
    css_parts = maybe_add_align_items_css(css_parts, hbox.align_items, :row)
    css_parts = maybe_add_justify_content_css(css_parts, hbox.justify_content, :row)

    style = Style.to_css(hbox.style)
    css_parts = if style, do: [style | css_parts], else: css_parts
    css = Enum.reverse(css_parts) |> Enum.join("; ")
    attrs = build_attributes([{"style", css}])

    ~s(<div#{attrs}>#{Enum.join(children_html)}</div>)
  end

  defp format_root_output(html, :html), do: html
  defp format_root_output(html, :heex), do: to_heex_template(html)

  defp put_config(%State{} = renderer_state, config) when is_list(config) do
    %{renderer_state | config: config}
  end

  defp maybe_put_root(%State{} = renderer_state, _new_root, false) do
    renderer_state
  end

  defp maybe_put_root(%State{} = renderer_state, new_root, true) do
    State.put_root(renderer_state, new_root)
  end

  defp maybe_bump_version(%State{} = renderer_state, false) do
    renderer_state
  end

  defp maybe_bump_version(%State{} = renderer_state, true) do
    State.bump_version(renderer_state)
  end

  defp render_output(iur_tree, renderer_state, :html) do
    convert_iur(iur_tree, renderer_state)
  end

  defp render_output(iur_tree, renderer_state, :heex) do
    iur_tree
    |> convert_iur(renderer_state)
    |> to_heex_template()
  end

  defp output_format(opts) when is_list(opts) do
    case Keyword.get(opts, :format) || Keyword.get(opts, :template) do
      :heex -> :heex
      _ -> :html
    end
  end

  defp to_heex_template(html) when is_binary(html) do
    String.trim(html)
  end
end
