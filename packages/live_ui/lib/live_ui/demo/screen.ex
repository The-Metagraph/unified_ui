defmodule LiveUi.Demo.Screen do
  @moduledoc """
  Package-local demo screen that turns the `live_ui` example catalog into a
  navigable workbench.
  """

  use LiveUi.Screen, id: :live_ui_demo, title: "Live UI Demo"

  alias LiveUi.Demo
  alias LiveUi.Demo.{Catalog, Style}

  @impl true
  def mount_defaults do
    %{
      view: :home,
      selected_category: Catalog.default_category(),
      selected_example: nil
    }
  end

  @impl true
  def render(assigns) do
    current_category =
      Catalog.normalize_category(assigns.selected_category) || Catalog.default_category()

    selected_example = Catalog.find_example(assigns.selected_example)

    assigns =
      assigns
      |> Map.put(:current_category, current_category)
      |> Map.put(:current_lane, Catalog.category_info(current_category))
      |> Map.put(:selected_example_metadata, selected_example)
      |> Map.put(:preview, preview_for(selected_example))
      |> Map.put(:categories, Enum.map(Catalog.categories(), &Catalog.category_info/1))
      |> Map.put(:sidebar_examples, Catalog.category_examples(current_category))
      |> Map.put(:total_examples, Catalog.total_example_count())
      |> Map.put(:path_counts, Catalog.path_counts())
      |> Map.put(:shell_style, Style.shell())
      |> Map.put(:stack_style, Style.layout(:column, "live-ui-demo-stack"))
      |> Map.put(:row_style, Style.layout(:row, "live-ui-demo-row"))

    ~H"""
    <LiveUi.Widgets.ScreenShell.render id="live-ui-demo" title={title()} {@shell_style}>
      <LiveUi.Layout.Column.render id="live-ui-demo-stack" gap="lg" {@stack_style}>
        <%= browser_header(assigns) %>
        <LiveUi.Layout.Row.render id="live-ui-demo-layout" gap="lg" {@row_style}>
          <%= sidebar(assigns) %>
          <%= content(assigns) %>
        </LiveUi.Layout.Row.render>
      </LiveUi.Layout.Column.render>
    </LiveUi.Widgets.ScreenShell.render>
    """
  end

  def metadata do
    %{
      id: :live_ui_demo,
      title: title(),
      families: [:styling, :navigation, :comparison],
      comparable_to: nil,
      summary:
        "Package-local `live_ui` workbench for maintained native, canonical, and mixed examples."
    }
  end

  defp browser_header(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-browser-header"))
      |> Map.put(:kicker_style, Style.text("live-ui-demo-browser-kicker", tone: :accent))
      |> Map.put(:badge_style, Style.text("live-ui-demo-browser-badge"))
      |> Map.put(:title_style, Style.text("live-ui-demo-browser-title", tone: :success))
      |> Map.put(:summary_style, Style.text("live-ui-demo-browser-summary"))
      |> Map.put(:notes_style, Style.text("live-ui-demo-browser-notes"))
      |> Map.put(:status_style, Style.text("live-ui-demo-browser-status"))
      |> Map.put(:metric_style, Style.text("live-ui-demo-metric"))
      |> Map.put(:header_top_style, Style.layout(:row, "live-ui-demo-browser-header-top"))
      |> Map.put(:header_copy_style, Style.layout(:column, "live-ui-demo-browser-copy"))
      |> Map.put(:toolbar_style, Style.layout(:row, "live-ui-demo-browser-toolbar"))
      |> Map.put(
        :overview_button_style,
        Style.button("live-ui-demo-home-button", variant: :quiet)
      )
      |> Map.put(:overview_path, overview_path(assigns.current_category))
      |> Map.put(
        :status_copy,
        current_status(assigns.current_category, assigns.selected_example_metadata)
      )

    ~H"""
    <LiveUi.Widgets.Box.render
      id="live-ui-demo-browser-header"
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
      <LiveUi.Layout.Row.render id="live-ui-demo-browser-header-top" gap="lg" {@header_top_style}>
        <LiveUi.Layout.Column.render id="live-ui-demo-browser-copy" gap="sm" {@header_copy_style}>
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-browser-kicker"
            content="live_ui package demo"
            {@kicker_style}
          />
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-browser-title"
            content="Live UI Workbench"
            {@title_style}
          />
        </LiveUi.Layout.Column.render>

        <LiveUi.Widgets.Text.render
          id="live-ui-demo-browser-badge"
          content="browser host"
          {@badge_style}
        />
      </LiveUi.Layout.Row.render>

      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-summary"
        content={
          "Browse the package-local demo through the same server-authoritative runtime the package exposes everywhere else."
        }
        {@summary_style}
      />

      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-notes"
        content={
          "Phoenix is only hosting the session here. The visible demo shell, lane navigation, and example content all render through live_ui."
        }
        {@notes_style}
      />

      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-status"
        content={@status_copy}
        {@status_style}
      />

      <LiveUi.Layout.Row.render id="live-ui-demo-browser-toolbar" gap="md" {@toolbar_style}>
        <div>
          <%= nav_link(
            "live-ui-demo-home-action",
            "Overview",
            @overview_path,
            @overview_button_style
          ) %>
        </div>

        <div class="live-ui-demo-metrics">
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-metric-total"
            content={"Examples: #{@total_examples}"}
            {@metric_style}
          />
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-metric-native"
            content={"Native: #{Map.get(@path_counts, :native, 0)}"}
            {@metric_style}
          />
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-metric-canonical"
            content={"Canonical: #{Map.get(@path_counts, :canonical, 0)}"}
            {@metric_style}
          />
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-metric-mixed"
            content={"Mixed: #{Map.get(@path_counts, :mixed, 0)}"}
            {@metric_style}
          />
        </div>
      </LiveUi.Layout.Row.render>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp sidebar(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-sidebar"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-sidebar-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-sidebar" padding="lg" border="subtle" background="panel" {@panel_style}>
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-sidebar-title"
        content="Explore Lanes"
        {@muted_style}
      />

      <div class="live-ui-demo-sidebar-group live-ui-demo-sidebar-lanes">
        <%= for category <- @categories do %>
          <%= category_button(assigns, category) %>
        <% end %>
      </div>

      <LiveUi.Widgets.Text.render
        id="live-ui-demo-sidebar-examples-title"
        content="Examples in this lane"
        {@muted_style}
      />

      <div class="live-ui-demo-sidebar-group live-ui-demo-sidebar-examples">
        <%= for example <- @sidebar_examples do %>
          <%= example_button(assigns, example) %>
        <% end %>
      </div>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp category_button(assigns, category) do
    button_style =
      if category.id == assigns.current_category do
        Style.button("live-ui-demo-category-button is-current", variant: :solid, state: :active)
      else
        Style.button("live-ui-demo-category-button", variant: :quiet)
      end

    assigns =
      assigns
      |> Map.put(:category, category)
      |> Map.put(:button_style, button_style)
      |> Map.put(:category_path, category_path(category.id))

    ~H"""
    <%= nav_link(
      "live-ui-demo-category-#{@category.id}",
      "#{@category.title} (#{@category.example_count})",
      @category_path,
      @button_style
    ) %>
    """
  end

  defp example_button(assigns, example) do
    selected? =
      assigns.selected_example_metadata && assigns.selected_example_metadata.id == example.id

    button_style =
      if selected? do
        Style.button("live-ui-demo-example-button is-current", variant: :solid, state: :active)
      else
        Style.button("live-ui-demo-example-button", variant: :quiet)
      end

    assigns =
      assigns
      |> Map.put(:example, example)
      |> Map.put(:button_style, button_style)
      |> Map.put(:example_path, example_path(example.id, assigns.current_category))

    ~H"""
    <%= nav_link(
      "live-ui-demo-example-#{@example.id}",
      @example.title,
      @example_path,
      @button_style
    ) %>
    """
  end

  defp content(%{view: :example} = assigns) when not is_nil(assigns.selected_example_metadata) do
    example = assigns.selected_example_metadata

    assigns =
      assigns
      |> Map.put(:example, example)
      |> Map.put(:panel_style, Style.panel("live-ui-demo-content"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-content-copy"))
      |> Map.put(:title_style, Style.text("live-ui-demo-content-title", tone: :accent))
      |> Map.put(:home_button_style, Style.button("live-ui-demo-back-button", variant: :quiet))
      |> Map.put(
        :breadcrumb_link_style,
        Style.link("live-ui-demo-breadcrumb-link", tone: :accent)
      )
      |> Map.put(
        :breadcrumb_current_style,
        Style.text("live-ui-demo-breadcrumb-current", tone: :success)
      )
      |> Map.put(:breadcrumb_separator_style, Style.text("live-ui-demo-breadcrumb-separator"))
      |> Map.put(:overview_path, overview_path(assigns.current_category))
      |> Map.put(:category_path, category_path(assigns.current_category))

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-content" gap="lg" {@stack_style}>
      <LiveUi.Widgets.Box.render id="live-ui-demo-example-header" padding="lg" border="subtle" background="panel" {@panel_style}>
        <%= nav_link(
          "live-ui-demo-example-home",
          "Back To Overview",
          @overview_path,
          @home_button_style
        ) %>
        <nav class="live-ui-demo-example-breadcrumbs" aria-label="Demo navigation breadcrumbs">
          <%= nav_link(
            "live-ui-demo-breadcrumb-overview",
            "Overview",
            @overview_path,
            @breadcrumb_link_style
          ) %>
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-breadcrumb-separator-overview"
            content="/"
            {@breadcrumb_separator_style}
          />
          <%= nav_link(
            "live-ui-demo-breadcrumb-category",
            @current_lane.title,
            @category_path,
            @breadcrumb_link_style
          ) %>
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-breadcrumb-separator-category"
            content="/"
            {@breadcrumb_separator_style}
          />
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-breadcrumb-current"
            content={@example.title}
            {@breadcrumb_current_style}
          />
        </nav>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-example-title"
          content={@example.title}
          {@title_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-example-summary"
          content={@example.summary}
          {@muted_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-example-categories"
          content={"Lanes: " <> Enum.map_join(@example.categories, ", ", &Atom.to_string/1)}
          {@muted_style}
        />
      </LiveUi.Widgets.Box.render>

      <%= preview_panel(assigns) %>
      <%= metadata_panel(assigns) %>
    </LiveUi.Layout.Column.render>
    """
  end

  defp content(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-home-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-home-copy"))
      |> Map.put(:title_style, Style.text("live-ui-demo-home-title", tone: :accent))

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-home" gap="lg" {@stack_style}>
      <LiveUi.Widgets.Box.render id="live-ui-demo-hero" padding="lg" border="subtle" background="panel" {@panel_style}>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-hero-kicker"
          content="Maintained Runtime Surfaces"
          {@muted_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-hero-title"
          content="One workbench across native, canonical, and mixed example paths."
          {@title_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-hero-copy"
          content={
            "Use the left sidebar to switch lanes and open a maintained example without leaving the shared runtime surface."
          }
          {@muted_style}
        />
      </LiveUi.Widgets.Box.render>

      <LiveUi.Widgets.Box.render id="live-ui-demo-lane-summary" padding="lg" border="subtle" background="panel" {@panel_style}>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-lane-summary-title"
          content={"Current lane: #{@current_lane.title}"}
          {@title_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-lane-summary-copy"
          content={@current_lane.description}
          {@muted_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-lane-summary-featured"
          content={"Featured example: #{@current_lane.featured_example.title}"}
          {@muted_style}
        />
        <div class="live-ui-demo-overview-list">
          <%= for example <- Enum.take(@sidebar_examples, 4) do %>
            <LiveUi.Widgets.Text.render
              id={"live-ui-demo-overview-example-#{example.id}"}
              content={"Example: #{example.title}"}
              {@muted_style}
            />
          <% end %>
        </div>
      </LiveUi.Widgets.Box.render>
    </LiveUi.Layout.Column.render>
    """
  end

  defp preview_panel(%{preview: %{mode: :html} = preview} = assigns) do
    assigns =
      assigns
      |> Map.put(:preview_data, preview)
      |> Map.put(:panel_style, Style.panel("live-ui-demo-preview-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-preview-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-preview" padding="lg" border="subtle" background="panel" {@panel_style}>
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-preview-title"
        content="Rendered Preview"
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-preview-details"
        content={
          "Widgets: #{length(@preview_data.widgets)} | Event routes: #{length(@preview_data.event_routes)} | Hooks: #{length(@preview_data.bridge_hooks)}"
        }
        {@muted_style}
      />
      <div><%= Phoenix.HTML.raw(@preview_data.html) %></div>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview_panel(%{preview: %{mode: :report} = preview} = assigns) do
    assigns =
      assigns
      |> Map.put(:preview_data, preview)
      |> Map.put(:panel_style, Style.panel("live-ui-demo-preview-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-preview-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-preview-report" padding="lg" border="subtle" background="panel" {@panel_style}>
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-preview-report-title"
        content="Comparison Report"
        {@muted_style}
      />
      <pre><%= @preview_data.report %></pre>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview_panel(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-preview-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-preview-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-preview-empty" padding="lg" border="subtle" background="panel" {@panel_style}>
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-preview-empty-text"
        content="No preview is available for the current selection."
        {@muted_style}
      />
    </LiveUi.Widgets.Box.render>
    """
  end

  defp metadata_panel(assigns) do
    preview = assigns.preview || %{}

    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-metadata-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-metadata-copy"))
      |> Map.put(:preview, preview)

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-metadata" padding="lg" border="subtle" background="panel" {@panel_style}>
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-metadata-title"
        content="Review Metadata"
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-metadata-artifact"
        content={"Artifact: #{@example.review_artifact}"}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-metadata-families"
        content={"Families: " <> Enum.map_join(@example.families, ", ", &Atom.to_string/1)}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-metadata-coverage"
        content={
          "Coverage: native=#{@example.coverage.native?} canonical=#{@example.coverage.canonical?} transport=#{@example.coverage.transport?}"
        }
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        :if={Map.has_key?(@preview, :event_routes)}
        id="live-ui-demo-metadata-routes"
        content={"Event routes: " <> inspect(@preview.event_routes)}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        :if={Map.has_key?(@preview, :bridge_hooks)}
        id="live-ui-demo-metadata-hooks"
        content={"Bridge hooks: " <> inspect(@preview.bridge_hooks)}
        {@muted_style}
      />
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview_for(nil), do: nil

  defp preview_for(example) do
    case Catalog.preview(example.id) do
      {:ok, preview} -> preview
      {:error, reason} -> %{mode: :error, reason: reason}
    end
  end

  defp overview_path(category) do
    Demo.path(category: category)
  end

  defp category_path(category) do
    Demo.path(category: category)
  end

  defp example_path(example, category) do
    Demo.path(example: example, category: category)
  end

  defp current_status(category, nil) do
    category_label =
      category
      |> Catalog.normalize_category()
      |> case do
        nil -> "native"
        value -> Atom.to_string(value)
      end

    "Current lane: #{category_label}. Use the left sidebar to open any example in that lane."
  end

  defp current_status(category, example) do
    category_label =
      category
      |> Catalog.normalize_category()
      |> case do
        nil -> "native"
        value -> Atom.to_string(value)
      end

    "Current lane: #{category_label}. Focused example: #{example.title}."
  end

  defp nav_link(id, label, path, style) do
    assigns = %{
      link_id: id,
      label: label,
      path: path,
      style: style,
      link_attrs: Map.get(style, :rest, %{}),
      tone: Map.get(style, :tone),
      variant: Map.get(style, :variant),
      state: Map.get(style, :state)
    }

    ~H"""
    <.link
      patch={@path}
      id={@link_id}
      class={@style.class}
      data-live-ui-widget="link"
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      {@link_attrs}
    >
      <%= @label %>
    </.link>
    """
  end
end
