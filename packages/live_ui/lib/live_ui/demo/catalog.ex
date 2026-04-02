defmodule LiveUi.Demo.Catalog do
  @moduledoc """
  Catalog helpers for the package-local `live_ui` demo workbench.
  """

  alias LiveUi.{Component, Examples}

  @category_order [
    :foundational,
    :input,
    :navigation,
    :data,
    :feedback,
    :operational,
    :overlay,
    :display
  ]

  @category_profiles %{
    foundational: %{
      title: "Foundational",
      description: "Core building-block widgets for text, structure, and shell composition."
    },
    input: %{
      title: "Input",
      description: "Form and value-entry widgets for text, toggle, and selection flows."
    },
    navigation: %{
      title: "Navigation",
      description: "Widgets that move users between views, commands, and destinations."
    },
    data: %{
      title: "Data",
      description: "Widgets for lists, tables, trees, and document-like information surfaces."
    },
    feedback: %{
      title: "Feedback",
      description: "Status and chart widgets that explain progress, health, and change over time."
    },
    operational: %{
      title: "Operational",
      description: "Monitoring and runtime-observability widgets for systems-oriented screens."
    },
    overlay: %{
      title: "Overlay",
      description: "Dialog and layered-surface widgets for transient or elevated interactions."
    },
    display: %{
      title: "Display",
      description: "Viewport and canvas-oriented widgets for advanced presentation surfaces."
    }
  }

  @spec categories() :: [atom()]
  def categories, do: @category_order

  @spec default_category() :: atom()
  def default_category, do: :foundational

  @spec category_count() :: non_neg_integer()
  def category_count, do: length(categories())

  @spec total_example_count() :: non_neg_integer()
  def total_example_count, do: length(catalog())

  @spec path_counts() :: map()
  def path_counts do
    catalog()
    |> Enum.group_by(& &1.path)
    |> Enum.into(%{}, fn {path, entries} -> {path, length(entries)} end)
  end

  @spec catalog() :: [map()]
  def catalog do
    @category_order
    |> Enum.flat_map(&category_examples/1)
  end

  @spec normalize_category(atom() | String.t() | nil) :: atom() | nil
  def normalize_category(nil), do: nil

  def normalize_category(category) when is_atom(category) do
    if category in @category_order, do: category, else: nil
  end

  def normalize_category(category) when is_binary(category) do
    Enum.find(@category_order, &(Atom.to_string(&1) == category))
  end

  @spec category_info(atom()) :: map()
  def category_info(category) when category in @category_order do
    profile = Map.fetch!(@category_profiles, category)
    examples = category_examples(category)

    %{
      id: category,
      title: profile.title,
      description: profile.description,
      example_count: length(examples)
    }
  end

  @spec category_examples(atom()) :: [map()]
  def category_examples(category) when category in @category_order do
    category
    |> category_modules()
    |> Enum.map(&widget_example(&1, category))
  end

  @spec find_example(atom() | String.t() | nil) :: map() | nil
  def find_example(nil), do: nil

  def find_example(id) do
    wanted = to_string(id)

    Enum.find(catalog(), &(to_string(&1.id) == wanted)) || maintained_example(wanted)
  end

  @spec fetch_example(atom() | String.t()) :: {:ok, map()} | {:error, term()}
  def fetch_example(id) do
    case find_example(id) do
      nil -> {:error, :unknown_example}
      example -> {:ok, example}
    end
  end

  @spec primary_category(atom() | String.t() | map()) :: atom() | nil
  def primary_category(%{} = example) do
    Map.get(example, :primary_category, Map.get(example, :category))
  end

  def primary_category(id) do
    id
    |> find_example()
    |> primary_category()
  end

  @spec example_categories(map()) :: [atom()]
  def example_categories(%{} = example) do
    example
    |> primary_category()
    |> case do
      nil -> []
      category -> [category]
    end
  end

  @spec preview(atom() | String.t() | map()) :: {:ok, map()} | {:error, term()}
  def preview(example_or_id) do
    with {:ok, example} <- normalize_example(example_or_id) do
      preview_for(example)
    end
  end

  defp normalize_example(%{path: :widget} = example), do: {:ok, example}

  defp normalize_example(%{} = example) do
    {:ok, decorate_maintained_example(example)}
  end

  defp normalize_example(id) do
    fetch_example(id)
  end

  defp preview_for(%{path: :widget} = example) do
    {:ok,
     %{
       mode: :empty,
       example: example
     }}
  end

  defp preview_for(%{path: path, id: id}) when path in [:native, :canonical] do
    with {:ok, inspection} <- LiveUi.Tooling.preview_example(id) do
      {:ok,
       inspection.result
       |> Map.put(:mode, :html)
       |> Map.put(:runtime_mode, Map.get(inspection.result, :mode))
       |> Map.put(:native?, path == :native)
       |> Map.put(:canonical?, path == :canonical)}
    end
  end

  defp preview_for(%{path: :mixed, id: id} = example) do
    with {:ok, inspection} <- LiveUi.Tooling.inspect_example(id) do
      {:ok,
       %{
         mode: :report,
         example: example,
         report:
           inspect(inspection.result, pretty: true, width: 100, limit: :infinity, sort_maps: true)
       }}
    end
  end

  defp category_modules(:foundational), do: LiveUi.Widgets.Foundational.modules()
  defp category_modules(:input), do: LiveUi.Widgets.Input.modules()
  defp category_modules(:navigation), do: LiveUi.Widgets.Navigation.modules()
  defp category_modules(:data), do: LiveUi.Widgets.Data.modules()
  defp category_modules(:feedback), do: LiveUi.Widgets.Feedback.modules()
  defp category_modules(:operational), do: LiveUi.Widgets.Operational.modules()
  defp category_modules(:overlay), do: LiveUi.Widgets.Overlay.modules()
  defp category_modules(:display), do: LiveUi.Widgets.Display.modules()

  defp widget_example(module, category) do
    metadata = Component.metadata(module)
    category_title = category_title(category)
    family_title = titleize(metadata.family)

    %{
      id: metadata.name,
      title: titleize(metadata.name),
      module: module,
      path: :widget,
      category: category,
      categories: [category],
      primary_category: category,
      families: [metadata.family],
      comparable_to: nil,
      summary: widget_summary(metadata, category_title, family_title),
      preview_id: "widget:#{metadata.name}",
      review_artifact: "live_ui/widgets/#{metadata.name}",
      coverage: %{
        native?: false,
        canonical?: false,
        transport?: metadata.events != [],
        continuity?: false,
        advanced?: category in [:data, :feedback, :operational, :overlay, :display]
      },
      runtime_obligations: %{
        category: category,
        widget_family: metadata.family
      },
      component: %{
        family: metadata.family,
        name: metadata.name,
        assigns: metadata.assigns,
        slots: metadata.slots,
        style_hooks: metadata.style_hooks,
        events: metadata.events
      }
    }
  end

  defp widget_summary(metadata, category_title, family_title) do
    [
      family_sentence(family_title),
      slot_sentence(metadata.slots),
      event_sentence(metadata.events)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
    |> then(fn details -> "#{category_title} widget. #{details}" end)
  end

  defp family_sentence(family_title), do: "Belongs to the #{family_title} family."

  defp slot_sentence([]), do: "No slots."

  defp slot_sentence(slots) do
    "Slots: " <> Enum.map_join(slots, ", ", &titleize/1) <> "."
  end

  defp event_sentence([]), do: "No runtime events."

  defp event_sentence(events) do
    "Events: " <> Enum.map_join(events, ", ", &titleize/1) <> "."
  end

  defp category_title(category) do
    @category_profiles
    |> Map.fetch!(category)
    |> Map.fetch!(:title)
  end

  defp titleize(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> titleize()
  end

  defp titleize(value) when is_binary(value) do
    value
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp maintained_example(id) do
    case Examples.find(id) do
      {:ok, example} -> decorate_maintained_example(example)
      :error -> nil
    end
  end

  defp decorate_maintained_example(example) do
    example
    |> Map.put(:categories, [])
    |> Map.put(:primary_category, nil)
    |> Map.put(:hidden?, true)
  end
end
