defmodule UnifiedExamples.Demo do
  @moduledoc """
  Aggregate demo-app entrypoint for the unified examples suite.
  """

  use Phoenix.Component

  alias UnifiedExamples.Demo.Categories
  alias UnifiedExamples.Demo.Fixtures
  alias UnifiedExamples.Demo.SignalLab, as: SignalLabRuntime
  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Runtime
  alias UnifiedExamples.Shared.Template
  alias Phoenix.LiveView.Socket

  @app_root Path.expand("../..", __DIR__)

  use UnifiedExamples.Shared.App,
    app: :unified_example_demo,
    directory: "examples/demo",
    purpose: :aggregate_demo

  @spec category_registry() :: [map()]
  def category_registry, do: Categories.review_registry()

  @spec active_category_id() :: atom()
  def active_category_id, do: Categories.default_id()

  @spec review_summary() :: String.t()
  def review_summary do
    "Review #{Categories.count()} ordered control categories through one shared shell, with full galleries on every non-signal tab and a dedicated signal lab for cross-control interaction stories."
  end

  @spec launch_descriptor(keyword()) :: map()
  def launch_descriptor(opts \\ []) do
    port = Keyword.get(opts, :port, launch_port())

    %{
      directory: "demo",
      cwd: @app_root,
      argv: ["mix", "phx.server"],
      env: [{"PORT", Integer.to_string(port)}],
      path: launch_path(),
      url: "http://127.0.0.1:#{port}#{launch_path()}",
      command: "cd #{@app_root} && PORT=#{port} mix phx.server"
    }
  end

  @spec review_metadata() :: map()
  def review_metadata do
    category_registry = category_registry()
    screen_module = screen_module()

    metadata()
    |> Map.take([
      :id,
      :root_id,
      :title,
      :summary,
      :notes,
      :widget,
      :theme_id,
      :directory,
      :purpose,
      :active_category_id,
      :category_count,
      :category_ids,
      :category_registry,
      :interaction_demo,
      :review_summary,
      :fixture_contract,
      :launch_path,
      :launch_url,
      :launch_command
    ])
    |> Map.merge(%{
      app_root: @app_root,
      default_theme_id: screen_module.default_theme_id(),
      style_profile: screen_module.shared_style_profile(),
      uses_shared_template:
        screen_module.shared_style_profile() == Template.default_style_profile(),
      application_module: application_module(),
      endpoint_module: endpoint_module(),
      router_module: router_module(),
      live_module: live_module(),
      dev_server_enabled?: Keyword.get(endpoint_config(), :server, false) == true,
      browser_runnable?: true,
      category_example_directories: Map.new(category_registry, &{&1.id, &1.example_directories}),
      linked_example_directories:
        category_registry
        |> Enum.flat_map(& &1.example_directories)
        |> Enum.uniq()
        |> Enum.sort(),
      signal_lab_contract: Categories.SignalLab.story_contract_summary()
    })
  end

  @spec decorate_metadata(map()) :: map()
  def decorate_metadata(metadata) do
    launch = launch_descriptor()

    Map.merge(metadata, %{
      active_category_id: active_category_id(),
      category_count: Categories.count(),
      category_ids: Categories.ids(),
      category_registry: category_registry(),
      fixture_contract: Fixtures.contract_summary(),
      review_summary: review_summary(),
      launch_path: launch.path,
      launch_url: launch.url,
      launch_command: launch.command
    })
  end

  @spec mount_live(Socket.t()) :: Socket.t()
  def mount_live(%Socket{} = socket) do
    assign_category(socket, active_category_id())
  end

  @spec handle_live_event(String.t(), map(), Socket.t()) :: {:noreply, Socket.t()}
  def handle_live_event("select_category", %{"category" => category_id}, %Socket{} = socket) do
    {:noreply, assign_category(socket, normalize_category_id(category_id))}
  end

  def handle_live_event(
        "navigate_category_tabs",
        %{"category" => category_id, "key" => key},
        %Socket{} = socket
      ) do
    {:noreply,
     socket
     |> assign_category(next_category_id(normalize_category_id(category_id), key))
     |> Phoenix.Component.assign(:tab_navigation_hint, keyboard_navigation_hint(key))}
  end

  def handle_live_event(_event, _params, %Socket{} = socket), do: {:noreply, socket}

  def extra_content(assigns) do
    ~H"""
    <section
      id="demo-category-review-shell"
      class="example-app-runtime"
      data-demo-active-category={@active_category.id}
      data-demo-responsive-shell="true"
      data-demo-responsive-digest={@metadata.fixture_contract.digest}
      data-demo-two-column-min={@metadata.fixture_contract.responsive_layout.desktop_two_column_min_width}
      data-demo-single-column-max={@metadata.fixture_contract.responsive_layout.compact_single_column_max_width}
      data-demo-dense-stack-max={@metadata.fixture_contract.responsive_layout.dense_stack_max_width}
    >
      <section class="example-app-review">
        <div class="example-app-header-top">
          <p class="example-app-kicker">Aggregate category review</p>
          <span class="example-app-widget"><%= @active_category.label %></span>
        </div>

        <div class="live-ui-box live-ui-box-panel">
          <p class="example-app-kicker">
            Category <span data-demo-category-index={@active_category.order}><%= @active_category.order %></span>
            of <span data-demo-category-count={length(@category_registry)}><%= length(@category_registry) %></span>
          </p>

          <p id="demo-category-tab-hint" class="example-app-visually-hidden">
            Use Tab to focus the active category tab. Use Left and Right Arrow to move between
            categories, Home to jump to the first tab, and End to jump to the last tab.
          </p>

          <div
            class="demo-category-tab-bar"
            role="tablist"
            aria-label="Examples demo control categories"
            aria-describedby="demo-category-tab-hint"
            data-demo-tablist="true"
          >
            <%= for entry <- @category_registry do %>
              <LiveUi.Widgets.Button.render
                id={"demo-category-tab-#{entry.id}"}
                label={entry.label}
                class={"live-ui-button live-ui-button-#{if entry.id == @active_category.id, do: "solid", else: "quiet"}"}
                tone="accent"
                variant={if entry.id == @active_category.id, do: "solid", else: "quiet"}
                phx-click="select_category"
                phx-keydown="navigate_category_tabs"
                phx-value-category={entry.id}
                role="tab"
                aria-selected={to_string(entry.id == @active_category.id)}
                aria-controls="demo-category-active-panel"
                aria-describedby="demo-category-tab-hint"
                tabindex={if entry.id == @active_category.id, do: "0", else: "-1"}
                data-demo-tab-active={to_string(entry.id == @active_category.id)}
              />
            <% end %>
          </div>

          <p :if={@tab_navigation_hint} class="example-app-notes" data-demo-tab-navigation-hint="true">
            <%= @tab_navigation_hint %>
          </p>

          <h2 class="example-app-title"><%= @active_category.label %></h2>
          <p class="example-app-summary"><%= @active_category.summary %></p>
          <p class="example-app-notes">
            Catalog linkage: <code><%= @active_category.id %></code> in the aggregate demo registry.
          </p>
          <p class="example-app-notes" data-demo-fixture-digest="true">
            Fixture digest: <code><%= @metadata.fixture_contract.digest %></code>
          </p>

          <div
            class="example-app-example-links"
            data-demo-linked-examples={@active_category.example_count}
          >
            <p class="example-app-kicker">Linked example apps</p>

            <%= for example <- @active_category_examples do %>
              <div
                class="example-app-example-link"
                data-demo-example-link={example.directory}
                data-demo-example-widget={example.widget}
              >
                <code><%= example.directory %></code>
                <span><%= example.widget %></span>
              </div>
            <% end %>
          </div>
        </div>
      </section>

      <section
        id="demo-category-active-panel"
        class="example-app-runtime"
        data-demo-category-panel={@active_category.id}
        role="tabpanel"
        aria-labelledby={"demo-category-tab-#{@active_category.id}"}
        tabindex="0"
      >
        <div class="live-ui-box live-ui-box-panel" data-demo-panel-chrome="true">
          <p class="example-app-kicker">Representative gallery</p>
          <p class="example-app-notes">
            The selected category renders through its own authored `UnifiedUi` fragment and `LiveUi` runtime surface.
          </p>
          <p class="example-app-notes">
            Review focus: <%= @active_category.example_count %> linked example apps contribute to this category gallery.
          </p>
          <p class="example-app-notes" data-demo-responsive-contract="true">
            Responsive contract: two columns at <%= @metadata.fixture_contract.responsive_layout.desktop_two_column_min_width %>px and above, stacked review below that, and denser linked-example flow at <%= @metadata.fixture_contract.responsive_layout.dense_stack_max_width %>px and below.
          </p>
        </div>

        <.live_component
          module={LiveUi.Runtime.component()}
          id={@category_component.id}
          runtime_state={@category_component.runtime_state}
        />
      </section>
    </section>
    """
  end

  defp assign_category(%Socket{} = socket, category_id) do
    entry = Categories.review_entry!(category_id)

    socket
    |> Phoenix.Component.assign(:category_registry, category_registry())
    |> Phoenix.Component.assign(:active_category, entry)
    |> Phoenix.Component.assign(
      :active_category_examples,
      category_examples(entry.example_directories)
    )
    |> Phoenix.Component.assign(
      :category_component,
      category_component(entry.fragment_module)
    )
    |> Phoenix.Component.assign(:tab_navigation_hint, nil)
  end

  defp category_component(fragment_module) do
    case Runtime.component_assigns(fragment_module) do
      {:ok, assigns} ->
        if fragment_module == Categories.SignalLab do
          %{
            assigns
            | runtime_state: SignalLabRuntime.bootstrap_runtime_state(assigns.runtime_state)
          }
        else
          assigns
        end

      {:error, reason} ->
        raise "unable to mount category fragment #{inspect(fragment_module)}: #{inspect(reason)}"
    end
  end

  defp normalize_category_id(category_id) when is_atom(category_id), do: category_id

  defp normalize_category_id(category_id) when is_binary(category_id) do
    category_id
    |> String.to_existing_atom()
  rescue
    ArgumentError -> active_category_id()
  end

  defp next_category_id(current_id, key) do
    ids = Categories.ids()
    current_index = Enum.find_index(ids, &(&1 == current_id)) || 0

    case key do
      "ArrowRight" -> Enum.at(ids, rem(current_index + 1, length(ids)))
      "ArrowLeft" -> Enum.at(ids, rem(current_index - 1 + length(ids), length(ids)))
      "Home" -> hd(ids)
      "End" -> List.last(ids)
      _other -> current_id
    end
  end

  defp keyboard_navigation_hint("ArrowRight"),
    do: "Moved focus and selection to the next category tab."

  defp keyboard_navigation_hint("ArrowLeft"),
    do: "Moved focus and selection to the previous category tab."

  defp keyboard_navigation_hint("Home"),
    do: "Moved focus and selection to the first category tab."

  defp keyboard_navigation_hint("End"),
    do: "Moved focus and selection to the last category tab."

  defp keyboard_navigation_hint(_other), do: nil

  defp category_examples(directories) do
    Enum.map(directories, &Catalog.entry!/1)
  end
end
