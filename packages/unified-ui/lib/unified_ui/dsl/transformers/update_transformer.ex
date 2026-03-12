# credo:disable-for-this-file Credo.Check.Refactor.LongQuoteBlocks
defmodule UnifiedUi.Dsl.Transformers.UpdateTransformer do
  @moduledoc """
  Spark transformer that generates a DSL-driven `update/2` function.

  The generated `update/2` routes incoming signals by:
  1. Signal type (`click`, `change`, `submit`)
  2. A key extracted from signal data (`action`, `input_id`, `form_id`, etc.)
  3. DSL-declared handlers found on widgets/entities

  If no DSL route matches, it falls back to default handlers that return
  state unchanged. For matched routes, default handlers apply route-driven
  state updates. All default handlers are overridable.
  """

  use Spark.Dsl.Transformer

  alias Spark.Dsl.Transformer
  alias UnifiedUi.Dsl.CompileIndex
  alias UnifiedIUR.Widgets

  alias UnifiedUi.Widgets.{
    Canvas,
    Command,
    CommandPalette,
    ProcessMonitor,
    SplitPane,
    StreamWidget,
    Viewport
  }

  @click_signal_type "unified.button.clicked"
  @change_signal_type "unified.input.changed"
  @submit_signal_type "unified.form.submitted"

  @impl true
  @spec transform(Spark.Dsl.t()) :: {:ok, Spark.Dsl.t()} | {:error, term()}
  def transform(dsl_state) do
    routes = extract_routes(dsl_state)
    modal_scopes = extract_modal_scopes(dsl_state)
    click_routes = Macro.escape(routes.click)
    change_routes = Macro.escape(routes.change)
    submit_routes = Macro.escape(routes.submit)
    modal_scopes = Macro.escape(modal_scopes)

    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    code =
      quote do
        @impl true
        def update(state, %Jido.Signal{type: unquote(@click_signal_type)} = signal) do
          dispatch_click_signal(state, signal)
        end

        @impl true
        def update(state, %{type: unquote(@click_signal_type)} = signal) do
          dispatch_click_signal(state, signal)
        end

        @impl true
        def update(state, %Jido.Signal{type: unquote(@change_signal_type)} = signal) do
          dispatch_change_signal(state, signal)
        end

        @impl true
        def update(state, %{type: unquote(@change_signal_type)} = signal) do
          dispatch_change_signal(state, signal)
        end

        @impl true
        def update(state, %Jido.Signal{type: unquote(@submit_signal_type)} = signal) do
          dispatch_submit_signal(state, signal)
        end

        @impl true
        def update(state, %{type: unquote(@submit_signal_type)} = signal) do
          dispatch_submit_signal(state, signal)
        end

        @impl true
        def update(state, _signal) do
          state
        end

        defp dispatch_click_signal(state, signal) do
          if UnifiedUi.Dsl.Transformers.UpdateTransformer.modal_blocked?(
               state,
               signal,
               unquote(modal_scopes)
             ) do
            state
          else
            route =
              UnifiedUi.Dsl.Transformers.UpdateTransformer.find_matching_route(
                unquote(click_routes),
                signal,
                :click
              )

            case route do
              nil -> handle_click_signal(state, signal)
              route -> handle_click_signal(state, signal, route)
            end
          end
        end

        defp dispatch_change_signal(state, signal) do
          if UnifiedUi.Dsl.Transformers.UpdateTransformer.modal_blocked?(
               state,
               signal,
               unquote(modal_scopes)
             ) do
            state
          else
            route =
              UnifiedUi.Dsl.Transformers.UpdateTransformer.find_matching_route(
                unquote(change_routes),
                signal,
                :change
              )

            case route do
              nil -> handle_change_signal(state, signal)
              route -> handle_change_signal(state, signal, route)
            end
          end
        end

        defp dispatch_submit_signal(state, signal) do
          if UnifiedUi.Dsl.Transformers.UpdateTransformer.modal_blocked?(
               state,
               signal,
               unquote(modal_scopes)
             ) do
            state
          else
            route =
              UnifiedUi.Dsl.Transformers.UpdateTransformer.find_matching_route(
                unquote(submit_routes),
                signal,
                :submit
              )

            case route do
              nil -> handle_submit_signal(state, signal)
              route -> handle_submit_signal(state, signal, route)
            end
          end
        end

        @doc """
        Handles click signals from buttons/elements.
        """
        def handle_click_signal(state, _signal) do
          state
        end

        @doc """
        Handles click signals with a matched DSL route.
        """
        def handle_click_signal(state, signal, route) do
          UnifiedUi.Dsl.Transformers.UpdateTransformer.apply_route_update(
            :click,
            state,
            signal,
            route
          )
        end

        @doc """
        Handles change signals from inputs.
        """
        def handle_change_signal(state, _signal) do
          state
        end

        @doc """
        Handles change signals with a matched DSL route.
        """
        def handle_change_signal(state, signal, route) do
          UnifiedUi.Dsl.Transformers.UpdateTransformer.apply_route_update(
            :change,
            state,
            signal,
            route
          )
        end

        @doc """
        Handles submit signals from forms/inputs.
        """
        def handle_submit_signal(state, _signal) do
          state
        end

        @doc """
        Handles submit signals with a matched DSL route.
        """
        def handle_submit_signal(state, signal, route) do
          UnifiedUi.Dsl.Transformers.UpdateTransformer.apply_route_update(
            :submit,
            state,
            signal,
            route
          )
        end

        defoverridable handle_click_signal: 2
        defoverridable handle_click_signal: 3
        defoverridable handle_change_signal: 2
        defoverridable handle_change_signal: 3
        defoverridable handle_submit_signal: 2
        defoverridable handle_submit_signal: 3
      end

    {:ok, Transformer.eval(dsl_state, [], code)}
  end

  @doc """
  Indicates whether this transformer should run before another transformer.
  """
  @impl true
  @spec before?(module()) :: boolean()
  def before?(_other), do: false

  @doc """
  Indicates whether this transformer should run after another transformer.
  """
  @impl true
  @spec after?(module()) :: boolean()
  def after?(_other), do: false

  @doc """
  Indicates whether this transformer runs in the after-compile phase.
  """
  @impl true
  @spec after_compile?() :: boolean()
  def after_compile?, do: false

  @doc false
  @spec find_matching_route([map()], map(), :click | :change | :submit) :: map() | nil
  def find_matching_route(routes, signal, kind) when is_list(routes) do
    route_key = extract_route_key(kind, signal)
    signal_data = extract_signal_data(signal)
    source_keys = extract_source_keys(signal_data)
    action_keys = extract_action_keys(signal_data, route_key)

    Enum.find(routes, fn route -> route.source in source_keys end) ||
      Enum.find(routes, fn route -> route.key in action_keys end)
  end

  @doc false
  @spec modal_blocked?(map(), map(), map()) :: boolean()
  def modal_blocked?(state, signal, modal_scopes)
      when is_map(state) and is_map(modal_scopes) do
    source_id =
      signal
      |> extract_signal_data()
      |> extract_modal_source_id()

    cond do
      map_size(modal_scopes) == 0 ->
        false

      is_nil(source_id) ->
        false

      true ->
        case active_modal_allowed_ids(state, modal_scopes) do
          nil -> false
          allowed_ids -> not MapSet.member?(allowed_ids, source_id)
        end
    end
  end

  def modal_blocked?(_state, _signal, _modal_scopes), do: false

  @doc false
  @spec apply_route_update(:click | :change | :submit, map(), map(), map()) :: map()
  def apply_route_update(kind, state, signal, route) when is_map(state) and is_map(route) do
    case route.handler do
      {:mfa, module, function, args} ->
        invoke_mfa_route(module, function, args, state, signal, route)

      _ ->
        state
        |> Map.merge(default_route_updates(kind, signal, route))
    end
  end

  defp extract_signal_data(%Jido.Signal{data: data}) when is_map(data), do: data
  defp extract_signal_data(%{data: data}) when is_map(data), do: data
  defp extract_signal_data(_), do: %{}

  defp extract_route_key(:click, signal) do
    data = extract_signal_data(signal)

    Map.get(data, :action) ||
      Map.get(data, :button_id) ||
      Map.get(data, :widget_id) ||
      Map.get(data, :id)
  end

  defp extract_route_key(:change, signal) do
    data = extract_signal_data(signal)

    Map.get(data, :input_id) ||
      Map.get(data, :widget_id) ||
      Map.get(data, :field) ||
      Map.get(data, :action) ||
      Map.get(data, :id)
  end

  defp extract_route_key(:submit, signal) do
    data = extract_signal_data(signal)

    Map.get(data, :form_id) ||
      Map.get(data, :action) ||
      Map.get(data, :id)
  end

  defp extract_route_key(_kind, _signal), do: nil

  defp extract_source_keys(data) do
    [
      Map.get(data, :widget_id),
      Map.get(data, :button_id),
      Map.get(data, :input_id),
      Map.get(data, :form_id),
      Map.get(data, :id)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp extract_action_keys(data, route_key) do
    [
      route_key,
      Map.get(data, :action)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  defp default_route_updates(:click, _signal, route), do: route.payload

  defp default_route_updates(:change, signal, route) do
    signal_data = extract_signal_data(signal)
    input_key = route.source
    input_value = Map.get(signal_data, :value)

    route.payload
    |> maybe_put_input_value(input_key, input_value)
    |> maybe_put_pick_list_filter(route, signal_data)
    |> maybe_put_command_palette_filter(route, signal_data)
  end

  defp default_route_updates(:submit, signal, route) do
    signal_data = extract_signal_data(signal)
    submit_data = extract_submit_updates(signal_data)

    route.payload
    |> Map.merge(submit_data)
    |> maybe_put_form_validation(route, submit_data)
  end

  defp default_route_updates(_kind, _signal, _route), do: %{}

  defp extract_submit_updates(signal_data) do
    case Map.get(signal_data, :data) do
      form_data when is_map(form_data) ->
        form_data

      _ ->
        signal_data
        |> Map.drop([:form_id, :action, :platform, :widget_id, :button_id, :input_id, :id])
    end
  end

  defp invoke_mfa_route(module, function, args, state, signal, route) do
    result =
      cond do
        function_exported?(module, function, length(args) + 3) ->
          apply(module, function, [state, signal, route | args])

        function_exported?(module, function, length(args) + 2) ->
          apply(module, function, [state, signal | args])

        function_exported?(module, function, length(args) + 1) ->
          apply(module, function, [signal | args])

        function_exported?(module, function, length(args)) ->
          apply(module, function, args)

        true ->
          state
      end

    normalize_route_result(result, state)
  rescue
    _ -> state
  catch
    _, _ -> state
  end

  defp normalize_route_result(%{} = result, _fallback), do: result
  defp normalize_route_result({:ok, %{} = result}, _fallback), do: result
  defp normalize_route_result({:noreply, %{} = result}, _fallback), do: result
  defp normalize_route_result(_result, fallback), do: fallback

  defp extract_modal_scopes(dsl_state) do
    entities = collect_entities(dsl_state)

    modal_entities =
      Enum.flat_map(entities, fn
        %Widgets.Dialog{id: id, visible: visible} when is_atom(id) ->
          [%{id: id, default_visible: visible != false}]

        %Widgets.AlertDialog{id: id, visible: visible} when is_atom(id) ->
          [%{id: id, default_visible: visible != false}]

        %{name: name, attrs: attrs} when name in [:dialog, :alert_dialog] ->
          modal_id = attr_get(attrs, :id)

          if is_atom(modal_id) do
            [%{id: modal_id, default_visible: attr_get(attrs, :visible) != false}]
          else
            []
          end

        _ ->
          []
      end)

    dialog_button_ids =
      entities
      |> Enum.flat_map(fn
        %Widgets.DialogButton{id: id} when is_atom(id) ->
          [id]

        %{name: :dialog_button, attrs: attrs} ->
          case attr_get(attrs, :id) do
            id when is_atom(id) -> [id]
            _ -> []
          end

        _ ->
          []
      end)
      |> MapSet.new()

    Enum.reduce(modal_entities, %{}, fn %{id: modal_id, default_visible: default_visible}, acc ->
      allowed_ids = dialog_button_ids |> MapSet.put(modal_id)
      Map.put(acc, modal_id, %{default_visible: default_visible, allowed_ids: allowed_ids})
    end)
  end

  defp extract_routes(dsl_state) do
    entities = collect_entities(dsl_state)

    %{
      click: extract_click_routes(entities),
      change: extract_change_routes(entities),
      submit: extract_submit_routes(entities)
    }
  end

  defp collect_entities(dsl_state) do
    CompileIndex.get(dsl_state).flat
  end

  defp extract_modal_source_id(data) do
    [
      Map.get(data, :widget_id),
      Map.get(data, :button_id),
      Map.get(data, :input_id),
      Map.get(data, :form_id),
      Map.get(data, :id)
    ]
    |> Enum.find(&is_atom/1)
  end

  defp active_modal_allowed_ids(state, modal_scopes) do
    allowed =
      modal_scopes
      |> Enum.reduce(MapSet.new(), fn {modal_id,
                                       %{
                                         default_visible: default_visible,
                                         allowed_ids: allowed_ids
                                       }},
                                      acc ->
        if modal_active?(state, modal_id, default_visible) do
          MapSet.union(acc, allowed_ids)
        else
          acc
        end
      end)

    if MapSet.size(allowed) > 0, do: allowed, else: nil
  end

  defp modal_active?(state, modal_id, default_visible) do
    open_key = :"#{modal_id}_open"
    visible_key = :"#{modal_id}_visible"

    cond do
      Map.has_key?(state, open_key) -> state[open_key] not in [false, nil]
      Map.has_key?(state, visible_key) -> state[visible_key] not in [false, nil]
      true -> default_visible != false
    end
  end

  defp extract_click_routes(entities) do
    entities
    |> Enum.flat_map(fn
      %Widgets.Button{} = button ->
        [build_route(:click, button.on_click, button.id)]

      %{name: :button, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_click), attr_get(attrs, :id))]

      %Widgets.MenuItem{} = item ->
        [build_route(:click, item.action, item.id)]

      %{name: :menu_item, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :action), attr_get(attrs, :id))]

      %Widgets.Table{} = table ->
        [
          build_route(:click, table.on_row_select, table.id),
          build_route(:click, table.on_sort, table.id)
        ]

      %{name: :table, attrs: attrs} ->
        [
          build_route(:click, attr_get(attrs, :on_row_select), attr_get(attrs, :id)),
          build_route(:click, attr_get(attrs, :on_sort), attr_get(attrs, :id))
        ]

      %Widgets.Tabs{} = tabs ->
        [build_route(:click, tabs.on_change, tabs.id)]

      %{name: :tabs, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_change), attr_get(attrs, :id))]

      %Widgets.TreeView{} = tree ->
        [
          build_route(:click, tree.on_select, tree.id),
          build_route(:click, tree.on_toggle, tree.id)
        ]

      %{name: :tree_view, attrs: attrs} ->
        [
          build_route(:click, attr_get(attrs, :on_select), attr_get(attrs, :id)),
          build_route(:click, attr_get(attrs, :on_toggle), attr_get(attrs, :id))
        ]

      %Widgets.DialogButton{} = button ->
        [build_route(:click, button.action, button.id)]

      %{name: :dialog_button, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :action), attr_get(attrs, :id))]

      %Widgets.Dialog{} = dialog ->
        [build_route(:click, dialog.on_close, dialog.id)]

      %{name: :dialog, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_close), attr_get(attrs, :id))]

      %Widgets.AlertDialog{} = alert ->
        [
          build_route(:click, alert.on_confirm, alert.id),
          build_route(:click, alert.on_cancel, alert.id)
        ]

      %{name: :alert_dialog, attrs: attrs} ->
        [
          build_route(:click, attr_get(attrs, :on_confirm), attr_get(attrs, :id)),
          build_route(:click, attr_get(attrs, :on_cancel), attr_get(attrs, :id))
        ]

      %Widgets.Toast{} = toast ->
        [build_route(:click, toast.on_dismiss, toast.id)]

      %{name: :toast, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_dismiss), attr_get(attrs, :id))]

      %Canvas{} = canvas ->
        [build_route(:click, canvas.on_click, canvas.id)]

      %{name: :canvas, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_click), attr_get(attrs, :id))]

      %ProcessMonitor{} = process_monitor ->
        [build_route(:click, process_monitor.on_process_select, process_monitor.id)]

      %{name: :process_monitor, attrs: attrs} ->
        [build_route(:click, attr_get(attrs, :on_process_select), attr_get(attrs, :id))]

      _ ->
        []
    end)
    |> compact_routes()
  end

  defp extract_change_routes(entities) do
    entities
    |> Enum.flat_map(fn
      %Widgets.TextInput{} = input ->
        [build_route(:change, input.on_change, input.id)]

      %{name: :text_input, attrs: attrs} ->
        [build_route(:change, attr_get(attrs, :on_change), attr_get(attrs, :id))]

      %Widgets.PickList{} = pick_list ->
        [
          build_pick_list_change_route(
            pick_list.on_select,
            pick_list.id,
            pick_list.searchable,
            pick_list.options
          )
        ]

      %{name: :pick_list, attrs: attrs} ->
        [
          build_pick_list_change_route(
            attr_get(attrs, :on_select),
            attr_get(attrs, :id),
            attr_get(attrs, :searchable),
            attr_get(attrs, :options)
          )
        ]

      %Viewport{} = viewport ->
        [build_route(:change, viewport.on_scroll, viewport.id)]

      %{name: :viewport, attrs: attrs} ->
        [build_route(:change, attr_get(attrs, :on_scroll), attr_get(attrs, :id))]

      %SplitPane{} = split_pane ->
        [build_route(:change, split_pane.on_resize_change, split_pane.id)]

      %{name: :split_pane, attrs: attrs} ->
        [build_route(:change, attr_get(attrs, :on_resize_change), attr_get(attrs, :id))]

      %Canvas{} = canvas ->
        [build_route(:change, canvas.on_hover, canvas.id)]

      %{name: :canvas, attrs: attrs} ->
        [build_route(:change, attr_get(attrs, :on_hover), attr_get(attrs, :id))]

      %CommandPalette{} = palette ->
        [build_command_palette_change_route(palette.on_select, palette.id, palette.commands)]

      %{name: :command_palette, attrs: attrs} ->
        [
          build_command_palette_change_route(
            attr_get(attrs, :on_select),
            attr_get(attrs, :id),
            attr_get(attrs, :commands)
          )
        ]

      %StreamWidget{} = stream_widget ->
        [build_route(:change, stream_widget.on_item, stream_widget.id)]

      %{name: :stream_widget, attrs: attrs} ->
        [build_route(:change, attr_get(attrs, :on_item), attr_get(attrs, :id))]

      _ ->
        []
    end)
    |> compact_routes()
  end

  defp extract_submit_routes(entities) do
    entities
    |> Enum.flat_map(fn
      %Widgets.TextInput{} = input ->
        fallback = input.form_id || input.id
        [build_route(:submit, input.on_submit, fallback)]

      %{name: :text_input, attrs: attrs} ->
        fallback = attr_get(attrs, :form_id) || attr_get(attrs, :id)
        [build_route(:submit, attr_get(attrs, :on_submit), fallback)]

      %Widgets.FormBuilder{} = form_builder ->
        fallback = form_builder.action || form_builder.id
        [build_form_builder_submit_route(form_builder.on_submit, fallback, form_builder.fields)]

      %{name: :form_builder, attrs: attrs} ->
        fallback = attr_get(attrs, :action) || attr_get(attrs, :id)

        [
          build_form_builder_submit_route(
            attr_get(attrs, :on_submit),
            fallback,
            attr_get(attrs, :fields)
          )
        ]

      _ ->
        []
    end)
    |> compact_routes()
  end

  defp build_route(_kind, nil, _fallback_key), do: nil

  defp build_route(kind, handler, fallback_key) do
    key = handler_key(handler, fallback_key)

    if is_atom(key) do
      %{
        kind: kind,
        key: key,
        handler: normalize_handler(handler),
        payload: handler_payload(handler),
        source: fallback_key
      }
    else
      nil
    end
  end

  defp build_pick_list_change_route(handler, fallback_key, searchable, options) do
    case build_route(:change, handler, fallback_key) do
      nil ->
        nil

      route ->
        Map.merge(route, %{
          widget: :pick_list,
          searchable: searchable == true,
          options: normalize_pick_list_options(options)
        })
    end
  end

  defp build_command_palette_change_route(handler, fallback_key, commands) do
    case build_route(:change, handler, fallback_key) do
      nil ->
        nil

      route ->
        Map.merge(route, %{
          widget: :command_palette,
          commands: normalize_command_palette_commands(commands)
        })
    end
  end

  defp build_form_builder_submit_route(handler, fallback_key, fields) do
    case build_route(:submit, handler, fallback_key) do
      nil ->
        nil

      route ->
        Map.merge(route, %{
          widget: :form_builder,
          fields: normalize_form_builder_fields(fields)
        })
    end
  end

  defp compact_routes(routes) do
    routes
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce({MapSet.new(), []}, fn route, {seen, acc} ->
      dedupe_key = {route.key, route.source}

      if MapSet.member?(seen, dedupe_key) do
        {seen, acc}
      else
        {MapSet.put(seen, dedupe_key), [route | acc]}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp handler_key(handler, _fallback_key) when is_atom(handler), do: handler

  defp handler_key({signal_name, _payload}, _fallback_key) when is_atom(signal_name),
    do: signal_name

  defp handler_key({_module, _function, _args}, fallback_key), do: fallback_key
  defp handler_key(_handler, fallback_key), do: fallback_key

  defp normalize_handler(handler) when is_atom(handler), do: {:signal, handler}

  defp normalize_handler({signal_name, payload})
       when is_atom(signal_name) and is_map(payload) do
    {:signal_with_payload, signal_name, payload}
  end

  defp normalize_handler({module, function, args})
       when is_atom(module) and is_atom(function) and is_list(args) do
    {:mfa, module, function, args}
  end

  defp normalize_handler(other), do: {:unknown, other}

  defp handler_payload({_signal_name, payload}) when is_map(payload), do: payload
  defp handler_payload(_), do: %{}

  defp maybe_put_input_value(payload, input_key, input_value)
       when is_atom(input_key) and not is_nil(input_value) do
    Map.put(payload, input_key, input_value)
  end

  defp maybe_put_input_value(payload, _input_key, _input_value), do: payload

  defp maybe_put_pick_list_filter(payload, route, signal_data) do
    query =
      Map.get(signal_data, :query) || Map.get(signal_data, :search) ||
        Map.get(signal_data, :filter)

    source = Map.get(route, :source)
    searchable? = Map.get(route, :searchable) == true
    widget = Map.get(route, :widget)

    cond do
      widget != :pick_list ->
        payload

      searchable? != true ->
        payload

      not is_atom(source) ->
        payload

      not is_binary(query) ->
        payload

      true ->
        filtered_options = filter_pick_list_options(Map.get(route, :options, []), query)

        payload
        |> Map.put(:"#{source}_search_query", query)
        |> Map.put(:"#{source}_filtered_options", filtered_options)
    end
  end

  defp maybe_put_command_palette_filter(payload, route, signal_data) do
    query =
      Map.get(signal_data, :query) || Map.get(signal_data, :search) ||
        Map.get(signal_data, :filter)

    source = Map.get(route, :source)
    widget = Map.get(route, :widget)

    cond do
      widget != :command_palette ->
        payload

      not is_atom(source) ->
        payload

      not is_binary(query) ->
        payload

      true ->
        filtered_commands = filter_command_palette_commands(Map.get(route, :commands, []), query)

        payload
        |> Map.put(:"#{source}_search_query", query)
        |> Map.put(:"#{source}_filtered_commands", filtered_commands)
    end
  end

  defp maybe_put_form_validation(payload, route, submit_data) do
    source = Map.get(route, :source)
    widget = Map.get(route, :widget)

    cond do
      widget != :form_builder ->
        payload

      not is_atom(source) ->
        payload

      true ->
        errors = validate_form_builder_fields(Map.get(route, :fields, []), submit_data)
        valid? = map_size(errors) == 0

        payload
        |> Map.put(:"#{source}_valid", valid?)
        |> Map.put(:"#{source}_errors", errors)
    end
  end

  defp filter_pick_list_options(options, query) when is_list(options) and is_binary(query) do
    normalized_query =
      query
      |> String.trim()
      |> String.downcase()

    if normalized_query == "" do
      options
    else
      Enum.filter(options, fn option ->
        label =
          option
          |> pick_list_option_label()
          |> String.downcase()

        value =
          option
          |> pick_list_option_value()
          |> stringify_value()
          |> String.downcase()

        String.contains?(label, normalized_query) or String.contains?(value, normalized_query)
      end)
    end
  end

  defp filter_pick_list_options(options, _query) when is_list(options), do: options
  defp filter_pick_list_options(_options, _query), do: []

  defp pick_list_option_label(%{label: label}) when is_binary(label), do: label

  defp pick_list_option_label(option) do
    option
    |> pick_list_option_value()
    |> stringify_value()
  end

  defp pick_list_option_value(%{value: value}), do: value
  defp pick_list_option_value({value, _label}), do: value
  defp pick_list_option_value(option), do: option

  defp normalize_pick_list_options(nil), do: []

  defp normalize_pick_list_options(options) when is_list(options) do
    Enum.map(options, fn
      %Widgets.PickListOption{} = option ->
        %{value: option.value, label: option.label, disabled: option.disabled}

      {value, label} ->
        %{value: value, label: stringify_value(label), disabled: false}

      option when is_map(option) ->
        %{
          value: Map.get(option, :value) || Map.get(option, "value"),
          label:
            Map.get(option, :label) || Map.get(option, "label") ||
              stringify_value(Map.get(option, :value) || Map.get(option, "value")),
          disabled: Map.get(option, :disabled) || Map.get(option, "disabled") || false
        }

      option when is_list(option) ->
        normalize_pick_list_options([Enum.into(option, %{})]) |> List.first()

      option ->
        %{value: option, label: stringify_value(option), disabled: false}
    end)
  end

  defp normalize_pick_list_options(_options), do: []

  defp filter_command_palette_commands(commands, query)
       when is_list(commands) and is_binary(query) do
    normalized_query =
      query
      |> String.trim()
      |> String.downcase()

    if normalized_query == "" do
      commands
    else
      Enum.filter(commands, fn command ->
        id =
          command
          |> Map.get(:id)
          |> stringify_value()
          |> String.downcase()

        label =
          command
          |> Map.get(:label, "")
          |> stringify_value()
          |> String.downcase()

        description =
          command
          |> Map.get(:description, "")
          |> stringify_value()
          |> String.downcase()

        keywords =
          command
          |> Map.get(:keywords, [])
          |> List.wrap()
          |> Enum.map(&(&1 |> stringify_value() |> String.downcase()))

        String.contains?(id, normalized_query) or
          String.contains?(label, normalized_query) or
          String.contains?(description, normalized_query) or
          Enum.any?(keywords, &String.contains?(&1, normalized_query))
      end)
    end
  end

  defp filter_command_palette_commands(commands, _query) when is_list(commands), do: commands
  defp filter_command_palette_commands(_commands, _query), do: []

  defp normalize_command_palette_commands(nil), do: []

  defp normalize_command_palette_commands(commands) when is_list(commands) do
    Enum.map(commands, fn
      %Command{} = command ->
        %{
          id: command.id,
          label: command.label,
          description: command.description,
          shortcut: command.shortcut,
          keywords: List.wrap(command.keywords),
          disabled: command.disabled == true,
          visible: command.visible != false
        }

      {id, label} when is_atom(id) and is_binary(label) ->
        %{
          id: id,
          label: label,
          description: nil,
          shortcut: nil,
          keywords: [],
          disabled: false,
          visible: true
        }

      command when is_map(command) ->
        disabled =
          cond do
            Map.has_key?(command, :disabled) -> Map.get(command, :disabled) == true
            Map.has_key?(command, "disabled") -> Map.get(command, "disabled") == true
            true -> false
          end

        visible =
          cond do
            Map.has_key?(command, :visible) -> Map.get(command, :visible) != false
            Map.has_key?(command, "visible") -> Map.get(command, "visible") != false
            true -> true
          end

        %{
          id: Map.get(command, :id) || Map.get(command, "id"),
          label: Map.get(command, :label) || Map.get(command, "label"),
          description: Map.get(command, :description) || Map.get(command, "description"),
          shortcut: Map.get(command, :shortcut) || Map.get(command, "shortcut"),
          keywords:
            (Map.get(command, :keywords) || Map.get(command, "keywords") || []) |> List.wrap(),
          disabled: disabled,
          visible: visible
        }

      command when is_list(command) ->
        normalize_command_palette_commands([Enum.into(command, %{})]) |> List.first()

      command ->
        %{
          id: command,
          label: stringify_value(command),
          description: nil,
          shortcut: nil,
          keywords: [],
          disabled: false,
          visible: true
        }
    end)
  end

  defp normalize_command_palette_commands(_commands), do: []

  defp normalize_form_builder_fields(nil), do: []

  defp normalize_form_builder_fields(fields) when is_list(fields) do
    fields
    |> Enum.map(&normalize_form_builder_field/1)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_form_builder_fields(_fields), do: []

  defp normalize_form_builder_field(%Widgets.FormField{} = field) do
    %{
      name: field.name,
      type: field.type,
      required: field.required == true,
      options: normalize_pick_list_options(field.options)
    }
  end

  defp normalize_form_builder_field({name, type}) when is_atom(name) and is_atom(type) do
    %{name: name, type: type, required: false, options: []}
  end

  defp normalize_form_builder_field(field) when is_list(field) do
    field
    |> Enum.into(%{})
    |> normalize_form_builder_field()
  end

  defp normalize_form_builder_field(field) when is_map(field) do
    name = Map.get(field, :name) || Map.get(field, "name")
    type = Map.get(field, :type) || Map.get(field, "type")

    if is_atom(name) and is_atom(type) do
      %{
        name: name,
        type: type,
        required: (Map.get(field, :required) || Map.get(field, "required")) == true,
        options:
          normalize_pick_list_options(Map.get(field, :options) || Map.get(field, "options"))
      }
    else
      nil
    end
  end

  defp normalize_form_builder_field(_field), do: nil

  defp validate_form_builder_fields(fields, submit_data)
       when is_list(fields) and is_map(submit_data) do
    Enum.reduce(fields, %{}, fn field, acc ->
      case validate_form_builder_field(field, submit_data) do
        :ok ->
          acc

        {:error, field_name, reason} ->
          Map.update(acc, field_name, [reason], fn reasons -> reasons ++ [reason] end)
      end
    end)
  end

  defp validate_form_builder_fields(_fields, _submit_data), do: %{}

  defp validate_form_builder_field(%{name: name} = field, submit_data) when is_atom(name) do
    value = Map.get(submit_data, name)
    type = Map.get(field, :type)
    required? = Map.get(field, :required) == true

    cond do
      required? and blank_value?(value) ->
        {:error, name, :required}

      blank_value?(value) ->
        :ok

      type == :email and not valid_email_value?(value) ->
        {:error, name, :invalid_email}

      type == :number and not valid_number_value?(value) ->
        {:error, name, :invalid_number}

      type == :select and
          not valid_select_value?(value, Map.get(field, :options, [])) ->
        {:error, name, :invalid_option}

      type == :checkbox and not valid_checkbox_value?(value) ->
        {:error, name, :invalid_checkbox}

      true ->
        :ok
    end
  end

  defp validate_form_builder_field(_field, _submit_data), do: :ok

  defp blank_value?(nil), do: true
  defp blank_value?(value) when is_binary(value), do: String.trim(value) == ""
  defp blank_value?(value) when is_list(value), do: value == []
  defp blank_value?(_value), do: false

  defp valid_email_value?(value) when is_binary(value) do
    String.match?(value, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
  end

  defp valid_email_value?(_value), do: false

  defp valid_number_value?(value) when is_integer(value) or is_float(value), do: true

  defp valid_number_value?(value) when is_binary(value) do
    String.match?(String.trim(value), ~r/^-?\d+(\.\d+)?$/)
  end

  defp valid_number_value?(_value), do: false

  defp valid_checkbox_value?(value) do
    value in [true, false, "true", "false", "on", "off", "1", "0", 1, 0]
  end

  defp valid_select_value?(value, options) when is_list(options) do
    option_values =
      options
      |> Enum.map(&pick_list_option_value/1)

    value in option_values
  end

  defp valid_select_value?(_value, _options), do: false

  defp stringify_value(value) when is_binary(value), do: value
  defp stringify_value(value) when is_atom(value), do: Atom.to_string(value)
  defp stringify_value(value) when is_integer(value), do: Integer.to_string(value)
  defp stringify_value(value) when is_float(value), do: Float.to_string(value)
  defp stringify_value(value), do: inspect(value)

  defp attr_get(attrs, key) when is_map(attrs), do: Map.get(attrs, key)
  defp attr_get(attrs, key) when is_list(attrs), do: Keyword.get(attrs, key)
  defp attr_get(_attrs, _key), do: nil
end
