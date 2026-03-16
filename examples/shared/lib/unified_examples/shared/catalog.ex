defmodule UnifiedExamples.Shared.Catalog do
  @moduledoc """
  Shared review catalog for the currently implemented example applications.
  """

  alias UnifiedExamples.Shared.InteractionDemo

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
          shell_kind: shell_kind(),
          interaction_demo: InteractionDemo.t()
        }

  @catalog_headers [
    "directory",
    "widget",
    "family",
    "phase",
    "shell_kind",
    "interaction_family",
    "interaction_source",
    "interaction_outcome"
  ]

  @entries [
    %{
      directory: "button",
      widget: :button,
      family: :content,
      phase: 1,
      shell_kind: :box,
      interaction_demo: %{
        mode: :custom,
        family: :click,
        source: :primary_widget,
        trigger_label: nil,
        idle_prompt: "Click Save profile to emit the authored canonical button signal.",
        outcome:
          "The button example should make the primary action feel live and explain the emitted click signal in reviewer-friendly language."
      }
    },
    %{
      directory: "text",
      widget: :text,
      family: :content,
      phase: 1,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the text story",
        idle_prompt:
          "Use the shared trigger to spotlight the text example and see how its authored copy becomes a reviewed interaction story.",
        outcome:
          "The text example should spotlight its authored copy and explain why the shared trigger exists for otherwise passive content."
      }
    },
    %{
      directory: "text_input",
      widget: :text_input,
      family: :input,
      phase: 1,
      shell_kind: :box,
      interaction_demo: %{
        mode: :custom,
        family: :change,
        source: :primary_widget,
        trigger_label: nil,
        idle_prompt:
          "Type into the draft field to capture the authored change signal and latest value.",
        outcome:
          "The text input example should mirror the live draft value and explain the emitted change signal clearly."
      }
    },
    %{
      directory: "box",
      widget: :box,
      family: :layout,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Review the box layout story",
        idle_prompt:
          "Use the shared trigger to highlight how the box example frames spacing, grouping, and visual boundary choices.",
        outcome:
          "The box example should make the authored layout container feel intentional and easy to review in the browser."
      }
    },
    %{
      directory: "content",
      widget: :content,
      family: :layout,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Review the content story",
        idle_prompt:
          "Use the shared trigger to spotlight how the content container groups authored children into one reviewable story.",
        outcome:
          "The content example should make grouping and semantic containment obvious even before reading the underlying DSL."
      }
    },
    %{
      directory: "icon",
      widget: :icon,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the icon story",
        idle_prompt:
          "Use the shared trigger to spotlight the icon example and review how the glyph participates in the shared story.",
        outcome:
          "The icon example should explain the authored glyph choice and make the visual emphasis obvious to reviewers."
      }
    },
    %{
      directory: "image",
      widget: :image,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the image story",
        idle_prompt:
          "Use the shared trigger to spotlight the image example and review how the authored media is framed.",
        outcome:
          "The image example should make the media block feel intentional and show how passive visuals still participate in a meaningful interaction story."
      }
    },
    %{
      directory: "label",
      widget: :label,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the label relationship",
        idle_prompt:
          "Use the shared trigger to call out how the label example frames authored relationships for reviewers.",
        outcome:
          "The label example should make the authored label relationship easy to understand in the browser without inspecting source."
      }
    },
    %{
      directory: "link",
      widget: :link,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Review the link story",
        idle_prompt:
          "Use the shared trigger to review how the link example explains its authored destination before navigation.",
        outcome:
          "The link example should communicate the authored destination and make the navigation intent obvious before anyone follows it."
      }
    },
    %{
      directory: "separator",
      widget: :separator,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the separator story",
        idle_prompt:
          "Use the shared trigger to call out how the separator organizes the reviewed content.",
        outcome:
          "The separator example should explain the authored visual boundary and why it matters in the surrounding composition."
      }
    },
    %{
      directory: "spacer",
      widget: :spacer,
      family: :content,
      phase: 2,
      shell_kind: :box,
      interaction_demo: %{
        trigger_label: "Highlight the spacing story",
        idle_prompt:
          "Use the shared trigger to show how the spacer example explains authored rhythm and spacing.",
        outcome:
          "The spacer example should make invisible spacing choices easier to review through the shared interaction story."
      }
    },
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
    %{
      directory: "stream_widget",
      widget: :stream_widget,
      family: :operational,
      phase: 4,
      shell_kind: :box
    },
    %{
      directory: "process_monitor",
      widget: :process_monitor,
      family: :operational,
      phase: 4,
      shell_kind: :box
    },
    %{
      directory: "supervision_tree_viewer",
      widget: :supervision_tree_viewer,
      family: :operational,
      phase: 4,
      shell_kind: :box
    },
    %{
      directory: "cluster_dashboard",
      widget: :cluster_dashboard,
      family: :operational,
      phase: 4,
      shell_kind: :box
    },
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
    Enum.map(@entries, &decorate_entry/1)
  end

  @spec catalog_headers() :: [String.t()]
  def catalog_headers do
    @catalog_headers
  end

  @spec directories() :: [String.t()]
  def directories do
    entries()
    |> Enum.map(& &1.directory)
    |> Enum.sort()
  end

  @spec tsv() :: String.t()
  def tsv do
    [Enum.join(@catalog_headers, "\t") | Enum.map(entries(), &entry_row/1)]
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  @spec by_phase(pos_integer()) :: [entry()]
  def by_phase(phase) when is_integer(phase) and phase > 0 do
    Enum.filter(entries(), &(&1.phase == phase))
  end

  @spec by_family() :: %{optional(family()) => [entry()]}
  def by_family do
    Enum.group_by(entries(), & &1.family)
  end

  @spec advanced_families() :: [family()]
  def advanced_families do
    [:display, :overlay, :operational]
  end

  @spec advanced_entries() :: [entry()]
  def advanced_entries do
    Enum.filter(entries(), &(&1.family in advanced_families()))
  end

  @spec advanced_directories() :: [String.t()]
  def advanced_directories do
    advanced_entries()
    |> Enum.map(& &1.directory)
    |> Enum.sort()
  end

  @spec entry!(String.t() | atom()) :: entry()
  def entry!(directory) do
    directory = normalize_directory(directory)

    Enum.find(entries(), &(&1.directory == directory)) ||
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

  defp decorate_entry(entry) do
    override_demo = Map.get(entry, :interaction_demo, %{})

    entry
    |> Map.drop([:interaction_demo])
    |> Map.put(:interaction_demo, InteractionDemo.normalize(override_demo, entry))
  end

  defp entry_row(entry) do
    [
      entry.directory,
      Atom.to_string(entry.widget),
      Atom.to_string(entry.family),
      Integer.to_string(entry.phase),
      Atom.to_string(entry.shell_kind),
      Atom.to_string(entry.interaction_demo.family),
      Atom.to_string(entry.interaction_demo.source),
      entry.interaction_demo.outcome
    ]
    |> Enum.join("\t")
  end
end
