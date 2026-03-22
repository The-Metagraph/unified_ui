defmodule TerminalUi.Runtime.StyleResolver do
  @moduledoc """
  Shared style and theme resolution for native and canonical `terminal_ui`
  widgets.
  """

  alias TerminalUi.{Style, Theme, Widget}

  @spec resolve(Widget.t(), keyword()) :: map()
  def resolve(%Widget{} = widget, opts \\ []) do
    authored = Style.normalize(widget.styles)
    theme_name = Keyword.get(opts, :theme, Map.get(authored, :theme, default_theme()))
    theme = Theme.theme(theme_name)
    variant = Map.get(authored, :variant, Map.get(widget.metadata, :variant))
    semantic_role = Map.get(authored, :semantic_role)

    component_defaults = Theme.resolve_component_style(theme.id, widget.kind, variant)
    semantic_defaults = Map.get(theme.semantic_roles, semantic_role, %{})

    {token_styles, token_diagnostics} =
      resolve_theme_tokens(theme.id, Map.get(authored, :theme_tokens, %{}))

    {state_variant_styles, state_variant_diagnostics} =
      resolve_state_variants(widget.state, authored)

    resolved =
      component_defaults
      |> Theme.merge_styles(semantic_defaults)
      |> Theme.merge_styles(token_styles)
      |> Theme.merge_styles(drop_meta_styles(authored))
      |> Theme.merge_styles(state_variant_styles)
      |> Map.put(:theme, theme.id)
      |> maybe_put(:style_refs, Map.get(authored, :style_refs))

    %{
      theme: theme.id,
      resolved: resolved,
      diagnostics: token_diagnostics ++ state_variant_diagnostics,
      token_refs: Map.get(authored, :theme_tokens, %{}),
      active_states: active_states(widget.state)
    }
  end

  @spec responsibilities() :: [atom()]
  def responsibilities do
    [:theme_defaults, :variant_resolution, :semantic_role_resolution, :state_variant_resolution]
  end

  defp default_theme, do: Theme.default_theme().id

  defp resolve_theme_tokens(_theme_name, token_map) when map_size(token_map) == 0, do: {%{}, []}

  defp resolve_theme_tokens(theme_name, token_map) do
    Enum.reduce(token_map, {%{}, []}, fn {token_name, path}, {styles_acc, diag_acc} ->
      case normalize_token_path(path) do
        [] ->
          {styles_acc, diag_acc ++ [invalid_token_diagnostic(token_name, path)]}

        token_path ->
          case Theme.resolve_token(theme_name, token_path) do
            {:ok, styles} ->
              {Theme.merge_styles(styles_acc, styles), diag_acc}

            {:error, :unknown_token} ->
              {styles_acc, diag_acc ++ [unresolved_token_diagnostic(token_name, token_path)]}
          end
      end
    end)
  end

  defp resolve_state_variants(widget_state, authored_styles) do
    active = active_states(widget_state)
    variant_styles = Map.get(authored_styles, :state_variants, %{})

    resolved =
      active
      |> Enum.reduce(%{}, fn state, acc ->
        Theme.merge_styles(acc, Map.get(variant_styles, state, %{}))
      end)

    missing =
      active
      |> Enum.reject(&Map.has_key?(variant_styles, &1))

    diagnostics =
      if missing == [] do
        []
      else
        [%{level: :warning, reason: :missing_state_variant_styles, states: missing}]
      end

    {resolved, diagnostics}
  end

  defp active_states(state) do
    state
    |> Map.new()
    |> Enum.filter(fn {_state, value} -> value in [true, :active, :current] end)
    |> Enum.map(fn {state, _value} -> state end)
    |> Enum.filter(&(&1 in Style.state_variant_keys()))
  end

  defp normalize_token_path(path) when is_list(path) do
    Enum.map(path, fn
      value when is_binary(value) -> String.to_atom(value)
      value -> value
    end)
  end

  defp normalize_token_path(_path), do: []

  defp invalid_token_diagnostic(token_name, path) do
    %{level: :warning, reason: :invalid_theme_token_reference, token: token_name, path: path}
  end

  defp unresolved_token_diagnostic(token_name, token_path) do
    %{level: :warning, reason: :unresolved_theme_token, token: token_name, path: token_path}
  end

  defp drop_meta_styles(styles) do
    Map.drop(styles, [:theme, :hooks, :style_refs, :theme_tokens, :state_variants])
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, []), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
