defmodule TerminalUi.Theme do
  @moduledoc """
  Native theme catalog and token resolution helpers for `terminal_ui`.
  """

  @default_theme :terminal_default

  @themes %{
    terminal_default: %{
      id: :terminal_default,
      palette: %{
        canvas_fg: :content,
        canvas_bg: :default,
        accent_fg: :accent,
        accent_bg: :default,
        muted_fg: :muted,
        info_fg: :info,
        success_fg: :success,
        warning_fg: :warning,
        danger_fg: :danger
      },
      semantic_roles: %{
        title: %{fg: :content, attrs: [:bold]},
        body: %{fg: :content},
        label: %{fg: :muted, attrs: [:bold]},
        primary_action: %{fg: :accent, attrs: [:bold]},
        secondary_action: %{fg: :muted},
        status_info: %{fg: :info, attrs: [:bold]},
        status_warning: %{fg: :warning, attrs: [:bold]},
        status_danger: %{fg: :danger, attrs: [:bold]},
        highlight: %{fg: :accent, bg: :default, attrs: [:underline]}
      },
      component_defaults: %{
        text: %{semantic_role: :body},
        button: %{variant: :default, semantic_role: :primary_action, padding: :xs},
        text_input: %{variant: :outlined, border: :single, padding: :xs},
        menu: %{variant: :dense},
        status: %{variant: :terminal_notice, semantic_role: :status_info},
        dialog: %{border: :double, padding: :sm},
        command_palette: %{variant: :dense, border: :single},
        table: %{variant: :dense}
      },
      component_variants: %{
        button: %{
          default: %{attrs: [:bold]},
          quiet: %{fg: :muted},
          accented: %{fg: :accent, attrs: [:bold, :underline]}
        },
        text_input: %{
          outlined: %{border: :single, padding: :xs},
          dense: %{border: :single, padding: :none}
        },
        status: %{
          terminal_notice: %{border: :single, padding: :xs},
          quiet: %{fg: :muted}
        },
        dialog: %{
          default: %{border: :double, padding: :sm}
        }
      },
      tokens: %{
        text: %{
          hero: %{semantic_role: :title, attrs: [:bold, :underline]},
          subtle: %{semantic_role: :label, fg: :muted}
        },
        button: %{
          primary: %{variant: :accented, semantic_role: :primary_action},
          quiet: %{variant: :quiet, semantic_role: :secondary_action}
        },
        surface: %{
          panel: %{border: :single, padding: :sm}
        }
      }
    },
    high_contrast: %{
      id: :high_contrast,
      palette: %{
        canvas_fg: :content,
        canvas_bg: :default,
        accent_fg: :accent,
        accent_bg: :default,
        muted_fg: :content,
        info_fg: :info,
        success_fg: :success,
        warning_fg: :warning,
        danger_fg: :danger
      },
      semantic_roles: %{
        title: %{fg: :content, attrs: [:bold, :underline]},
        body: %{fg: :content, attrs: [:bold]},
        label: %{fg: :content, attrs: [:bold]},
        primary_action: %{fg: :accent, attrs: [:bold, :reverse]},
        secondary_action: %{fg: :content, attrs: [:underline]},
        status_info: %{fg: :info, attrs: [:bold, :reverse]},
        status_warning: %{fg: :warning, attrs: [:bold, :reverse]},
        status_danger: %{fg: :danger, attrs: [:bold, :reverse]},
        highlight: %{fg: :accent, attrs: [:bold, :underline, :reverse]}
      },
      component_defaults: %{
        text: %{semantic_role: :body},
        button: %{variant: :accented, semantic_role: :primary_action, padding: :xs},
        text_input: %{variant: :outlined, border: :double, padding: :xs},
        menu: %{variant: :dense},
        status: %{variant: :terminal_notice, semantic_role: :status_info},
        dialog: %{border: :heavy, padding: :sm},
        command_palette: %{variant: :dense, border: :double},
        table: %{variant: :dense}
      },
      component_variants: %{
        button: %{
          default: %{attrs: [:bold, :reverse]},
          quiet: %{attrs: [:underline]},
          accented: %{attrs: [:bold, :underline, :reverse]}
        },
        text_input: %{
          outlined: %{border: :double, padding: :xs}
        },
        status: %{
          terminal_notice: %{border: :double, padding: :xs}
        },
        dialog: %{
          default: %{border: :heavy, padding: :sm}
        }
      },
      tokens: %{
        text: %{
          hero: %{semantic_role: :title, attrs: [:bold, :underline, :reverse]}
        },
        button: %{
          primary: %{variant: :accented, semantic_role: :primary_action}
        },
        surface: %{
          panel: %{border: :double, padding: :sm}
        }
      }
    }
  }

  @spec default_theme() :: map()
  def default_theme, do: theme(@default_theme)

  @spec theme(atom() | String.t() | nil) :: map()
  def theme(name) when is_binary(name), do: name |> String.to_atom() |> theme()
  def theme(nil), do: theme(@default_theme)

  def theme(name) when is_atom(name) do
    Map.get(@themes, name, Map.fetch!(@themes, @default_theme))
  end

  @spec catalog() :: map()
  def catalog, do: @themes

  @spec catalog_ids() :: [atom()]
  def catalog_ids, do: Map.keys(@themes)

  @spec continuity_rules() :: map()
  def continuity_rules do
    %{
      inheritance_order: [:theme_defaults, :semantic_role, :variant_defaults, :local_styles],
      unresolved_tokens: :ignore_with_diagnostic,
      terminal_rendering: :deterministic
    }
  end

  @spec resolve_token(atom() | String.t() | nil, [atom() | String.t()]) ::
          {:ok, map()} | {:error, :unknown_token}
  def resolve_token(theme_name, token_path) when is_list(token_path) do
    token_path =
      Enum.map(token_path, fn
        value when is_binary(value) -> String.to_atom(value)
        value -> value
      end)

    case get_in(theme(theme_name), [:tokens | token_path]) do
      nil -> {:error, :unknown_token}
      styles -> {:ok, styles}
    end
  end

  @spec resolve_component_style(atom() | String.t() | nil, atom(), atom() | nil) :: map()
  def resolve_component_style(theme_name, kind, variant \\ nil) do
    theme = theme(theme_name)
    defaults = get_in(theme, [:component_defaults, kind]) || %{}
    variant_name = variant || Map.get(defaults, :variant)
    variant_defaults = get_in(theme, [:component_variants, kind, variant_name]) || %{}

    merge_styles(defaults, variant_defaults)
  end

  @spec merge_styles(map(), map()) :: map()
  def merge_styles(left, right) when left == %{}, do: right
  def merge_styles(left, right) when right == %{}, do: left

  def merge_styles(left, right) when is_map(left) and is_map(right) do
    Map.merge(left, right, fn _key, left_value, right_value ->
      cond do
        is_map(left_value) and is_map(right_value) ->
          merge_styles(left_value, right_value)

        is_list(left_value) and is_list(right_value) ->
          Enum.uniq(left_value ++ right_value)

        true ->
          right_value
      end
    end)
  end
end
