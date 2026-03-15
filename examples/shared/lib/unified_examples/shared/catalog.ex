defmodule UnifiedExamples.Shared.Catalog do
  @moduledoc """
  Shared review catalog for the currently implemented example applications.
  """

  @type shell_kind :: :box | :form_builder
  @type family ::
          :content
          | :layout
          | :display
          | :forms
          | :input
          | :navigation
          | :data
          | :feedback
          | :overlay
          | :operational

  @type entry :: %{
          directory: String.t(),
          widget: atom(),
          family: family(),
          phase: pos_integer(),
          shell_kind: shell_kind()
        }

  @entries [
    %{directory: "button", widget: :button, family: :content, phase: 1, shell_kind: :box},
    %{directory: "text", widget: :text, family: :content, phase: 1, shell_kind: :box},
    %{directory: "text_input", widget: :text_input, family: :input, phase: 1, shell_kind: :box},
    %{directory: "box", widget: :box, family: :layout, phase: 2, shell_kind: :box},
    %{directory: "content", widget: :content, family: :layout, phase: 2, shell_kind: :box},
    %{directory: "icon", widget: :icon, family: :content, phase: 2, shell_kind: :box},
    %{directory: "image", widget: :image, family: :content, phase: 2, shell_kind: :box},
    %{directory: "label", widget: :label, family: :content, phase: 2, shell_kind: :box},
    %{directory: "link", widget: :link, family: :content, phase: 2, shell_kind: :box},
    %{directory: "separator", widget: :separator, family: :content, phase: 2, shell_kind: :box},
    %{directory: "spacer", widget: :spacer, family: :content, phase: 2, shell_kind: :box},
    %{
      directory: "checkbox",
      widget: :checkbox,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "date_input",
      widget: :date_input,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{directory: "field", widget: :field, family: :forms, phase: 2, shell_kind: :form_builder},
    %{
      directory: "field_group",
      widget: :field_group,
      family: :forms,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "file_input",
      widget: :file_input,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "form_builder",
      widget: :form_builder,
      family: :forms,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "numeric_input",
      widget: :numeric_input,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "pick_list",
      widget: :pick_list,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{
      directory: "radio_group",
      widget: :radio_group,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{directory: "select", widget: :select, family: :input, phase: 2, shell_kind: :form_builder},
    %{
      directory: "time_input",
      widget: :time_input,
      family: :input,
      phase: 2,
      shell_kind: :form_builder
    },
    %{directory: "toggle", widget: :toggle, family: :input, phase: 2, shell_kind: :form_builder},
    %{directory: "row", widget: :row, family: :layout, phase: 3, shell_kind: :box},
    %{directory: "column", widget: :column, family: :layout, phase: 3, shell_kind: :box},
    %{directory: "grid", widget: :grid, family: :layout, phase: 3, shell_kind: :box},
    %{directory: "viewport", widget: :viewport, family: :display, phase: 4, shell_kind: :box},
    %{
      directory: "scroll_bar",
      widget: :scroll_bar,
      family: :display,
      phase: 4,
      shell_kind: :box
    },
    %{
      directory: "split_pane",
      widget: :split_pane,
      family: :display,
      phase: 4,
      shell_kind: :box
    },
    %{directory: "canvas", widget: :canvas, family: :display, phase: 4, shell_kind: :box},
    %{directory: "overlay", widget: :overlay, family: :overlay, phase: 4, shell_kind: :box},
    %{directory: "dialog", widget: :dialog, family: :overlay, phase: 4, shell_kind: :box},
    %{
      directory: "alert_dialog",
      widget: :alert_dialog,
      family: :overlay,
      phase: 4,
      shell_kind: :box
    },
    %{
      directory: "context_menu",
      widget: :context_menu,
      family: :overlay,
      phase: 4,
      shell_kind: :box
    },
    %{directory: "toast", widget: :toast, family: :overlay, phase: 4, shell_kind: :box},
    %{directory: "menu", widget: :menu, family: :navigation, phase: 3, shell_kind: :box},
    %{directory: "tabs", widget: :tabs, family: :navigation, phase: 3, shell_kind: :box},
    %{
      directory: "command_palette",
      widget: :command_palette,
      family: :navigation,
      phase: 3,
      shell_kind: :box
    },
    %{directory: "list", widget: :list, family: :data, phase: 3, shell_kind: :box},
    %{directory: "table", widget: :table, family: :data, phase: 3, shell_kind: :box},
    %{directory: "tree_view", widget: :tree_view, family: :data, phase: 3, shell_kind: :box},
    %{
      directory: "markdown_viewer",
      widget: :markdown_viewer,
      family: :data,
      phase: 3,
      shell_kind: :box
    },
    %{directory: "log_viewer", widget: :log_viewer, family: :data, phase: 3, shell_kind: :box},
    %{directory: "status", widget: :status, family: :feedback, phase: 3, shell_kind: :box},
    %{
      directory: "progress",
      widget: :progress,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    },
    %{directory: "gauge", widget: :gauge, family: :feedback, phase: 3, shell_kind: :box},
    %{
      directory: "inline_feedback",
      widget: :inline_feedback,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    },
    %{
      directory: "sparkline",
      widget: :sparkline,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    },
    %{
      directory: "bar_chart",
      widget: :bar_chart,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    },
    %{
      directory: "line_chart",
      widget: :line_chart,
      family: :feedback,
      phase: 3,
      shell_kind: :box
    }
  ]

  @spec entries() :: [entry()]
  def entries do
    @entries
  end

  @spec directories() :: [String.t()]
  def directories do
    @entries
    |> Enum.map(& &1.directory)
    |> Enum.sort()
  end

  @spec by_phase(pos_integer()) :: [entry()]
  def by_phase(phase) when is_integer(phase) and phase > 0 do
    Enum.filter(@entries, &(&1.phase == phase))
  end

  @spec by_family() :: %{optional(family()) => [entry()]}
  def by_family do
    Enum.group_by(@entries, & &1.family)
  end

  @spec entry!(String.t() | atom()) :: entry()
  def entry!(directory) do
    directory = normalize_directory(directory)

    Enum.find(@entries, &(&1.directory == directory)) ||
      raise ArgumentError, "unknown example directory: #{directory}"
  end

  @spec app_module(String.t() | atom()) :: module()
  def app_module(directory) do
    directory
    |> normalize_directory()
    |> Macro.camelize()
    |> then(&Module.concat([UnifiedExamples, &1]))
  end

  @spec screen_module(String.t() | atom()) :: module()
  def screen_module(directory) do
    Module.concat([app_module(directory), Screen])
  end

  @spec source_files(String.t() | atom()) :: [String.t()]
  def source_files(directory) do
    directory = normalize_directory(directory)
    app_root = Path.join(UnifiedExamples.Shared.suite_root(), directory)

    [
      Path.join(app_root, "lib/unified_examples/#{directory}/screen.ex"),
      Path.join(app_root, "lib/unified_examples/#{directory}.ex")
    ]
  end

  defp normalize_directory(directory) when is_atom(directory), do: Atom.to_string(directory)
  defp normalize_directory(directory) when is_binary(directory), do: directory
end
