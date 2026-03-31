defmodule LiveUi.Demo.Catalog do
  @moduledoc """
  Catalog helpers for the package-local `live_ui` demo workbench.
  """

  alias LiveUi.Examples

  @category_order [:native, :canonical, :mixed, :styling, :transport, :continuity]

  @category_profiles %{
    native: %{
      title: "Native",
      description: "Directly authored LiveView screens rendered through the shared runtime.",
      featured_example: :native_styled_profile
    },
    canonical: %{
      title: "Canonical",
      description: "UnifiedIUR-driven screens lowered through the same runtime boundary.",
      featured_example: :canonical_styled_operations
    },
    mixed: %{
      title: "Mixed",
      description: "Comparison-oriented review surfaces that keep multiple runtime paths visible.",
      featured_example: :styled_continuity_compare
    },
    styling: %{
      title: "Styling",
      description: "Theme-aware examples that exercise tone, continuity, and component styling hooks.",
      featured_example: :native_styled_operations
    },
    transport: %{
      title: "Transport",
      description: "Local, boundary, and canonical signal flows with their runtime translations.",
      featured_example: :boundary_transport_compare
    },
    continuity: %{
      title: "Continuity",
      description: "Paired native and canonical examples that should stay aligned as the package evolves.",
      featured_example: :native_styled_profile
    }
  }

  @spec categories() :: [atom()]
  def categories, do: @category_order

  @spec default_category() :: atom()
  def default_category, do: :native

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
    Examples.catalog()
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
    featured_example = find_example(profile.featured_example)

    %{
      id: category,
      title: profile.title,
      description: profile.description,
      featured_example: featured_example,
      example_count: length(examples)
    }
  end

  @spec category_examples(atom()) :: [map()]
  def category_examples(category) when category in @category_order do
    catalog()
    |> Enum.filter(&category_member?(&1, category))
    |> Enum.sort_by(&{path_rank(&1.path), &1.title})
  end

  @spec find_example(atom() | String.t() | nil) :: map() | nil
  def find_example(nil), do: nil

  def find_example(id) do
    case Examples.find(id) do
      {:ok, example} -> decorate_example(example)
      :error -> nil
    end
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
    example_categories(example)
    |> List.first()
  end

  def primary_category(id) do
    id
    |> find_example()
    |> primary_category()
  end

  @spec example_categories(map()) :: [atom()]
  def example_categories(%{} = example) do
    Enum.filter(@category_order, &category_member?(example, &1))
  end

  @spec preview(atom() | String.t() | map()) :: {:ok, map()} | {:error, term()}
  def preview(example_or_id) do
    with {:ok, example} <- normalize_example(example_or_id) do
      preview_for(example)
    end
  end

  defp normalize_example(%{} = example), do: {:ok, decorate_example(example)}

  defp normalize_example(id) do
    fetch_example(id)
  end

  defp preview_for(%{path: :native, module: module, id: id}) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount(module) do
      {:ok,
       runtime_preview(
         "demo-preview-native-#{id}",
         runtime_state,
         native?: true,
         canonical?: false
       )}
    end
  end

  defp preview_for(%{path: :canonical, module: module, id: id}) do
    with {:ok, runtime_state} <- LiveUi.Runtime.mount_iur(module.element()) do
      {:ok,
       runtime_preview(
         "demo-preview-canonical-#{id}",
         runtime_state,
         native?: false,
         canonical?: true
       )}
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

  defp runtime_preview(dom_id, runtime_state, opts) do
    html =
      LiveUi.Runtime.component().render(%{
        id: dom_id,
        runtime_state: runtime_state
      })
      |> Phoenix.HTML.Safe.to_iodata()
      |> IO.iodata_to_binary()

    %{
      mode: :html,
      html: html,
      widgets: widget_entries(html),
      event_routes: Map.keys(runtime_state.event_routes) |> Enum.sort(),
      bridge_hooks: Enum.sort(runtime_state.bridge_hooks),
      native?: Keyword.fetch!(opts, :native?),
      canonical?: Keyword.fetch!(opts, :canonical?)
    }
  end

  defp widget_entries(html) do
    ~r/<[^>]*data-live-ui-widget="[^"]+"[^>]*>/
    |> Regex.scan(html)
    |> Enum.map(fn [tag] ->
      %{
        id: attribute(tag, "id"),
        widget: attribute(tag, "data-live-ui-widget"),
        tone: attribute(tag, "data-live-ui-tone"),
        variant: attribute(tag, "data-live-ui-variant"),
        state: attribute(tag, "data-live-ui-state")
      }
    end)
  end

  defp attribute(tag, name) do
    case Regex.run(~r/#{Regex.escape(name)}="([^"]+)"/, tag, capture: :all_but_first) do
      [value] -> value
      _ -> nil
    end
  end

  defp decorate_example(example) do
    example
    |> Map.put(:categories, example_categories(example))
    |> Map.put(:primary_category, primary_category_without_recursion(example))
  end

  defp primary_category_without_recursion(example) do
    Enum.find(@category_order, &category_member?(example, &1))
  end

  defp category_member?(example, :native), do: example.path == :native
  defp category_member?(example, :canonical), do: example.path == :canonical
  defp category_member?(example, :mixed), do: example.path == :mixed
  defp category_member?(example, :styling), do: :styling in example.families

  defp category_member?(example, :transport) do
    :transport in example.families or :signal in example.families
  end

  defp category_member?(example, :continuity) do
    :continuity in example.families or not is_nil(example.comparable_to)
  end

  defp path_rank(:native), do: 0
  defp path_rank(:canonical), do: 1
  defp path_rank(:mixed), do: 2
end
