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
    current_category = Catalog.normalize_category(assigns.selected_category) || Catalog.default_category()
    selected_example = Catalog.find_example(assigns.selected_example)

    assigns =
      assigns
      |> Map.put(:current_category, current_category)
      |> Map.put(:selected_example_metadata, selected_example)
      |> Map.put(:preview, preview_for(selected_example))
      |> Map.put(:categories, Enum.map(Catalog.categories(), &Catalog.category_info/1))
      |> Map.put(:sidebar_examples, Catalog.category_examples(current_category))
      |> Map.put(:path_counts, Catalog.path_counts())
      |> Map.put(:shell_style, Style.shell())
      |> Map.put(:stack_style, Style.layout(:column, "live-ui-demo-stack"))
      |> Map.put(:row_style, Style.layout(:row, "live-ui-demo-row"))
      |> Map.put(:grid_style, Style.layout(:grid, "live-ui-demo-grid"))

    ~H"""
    <LiveUi.Widgets.ScreenShell.render id="live-ui-demo" title={title()} {@shell_style}>
      <LiveUi.Layout.Column.render id="live-ui-demo-stack" gap="lg" {@stack_style}>
        <%= topbar(assigns) %>
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
      summary: "Package-local `live_ui` workbench for maintained native, canonical, and mixed examples."
    }
  end

  defp topbar(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-topbar"))
      |> Map.put(:eyebrow_style, Style.text("live-ui-demo-eyebrow", tone: :accent))
      |> Map.put(:title_style, Style.text("live-ui-demo-title", tone: :success))
      |> Map.put(:muted_style, Style.text("live-ui-demo-muted"))
      |> Map.put(:home_button_style, Style.button("live-ui-demo-home-button", variant: :quiet))
      |> Map.put(:overview_path, overview_path(assigns.current_category))

    ~H"""
    <LiveUi.Widgets.Box.render id="live-ui-demo-topbar" padding="lg" border="subtle" background="panel" {@panel_style}>
      <div>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-kicker"
          content="Package Demo"
          {@eyebrow_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-heading"
          content="Live UI Workbench"
          {@title_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-summary"
          content={
            "Review native, canonical, and mixed example surfaces through the same server-authoritative runtime."
          }
          {@muted_style}
        />
      </div>

      <div>
        <%= nav_link("live-ui-demo-home-action", "Overview", @overview_path, @home_button_style) %>
      </div>

      <div>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-path-native"
          content={"Native: #{Map.get(@path_counts, :native, 0)}"}
          {@muted_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-path-canonical"
          content={"Canonical: #{Map.get(@path_counts, :canonical, 0)}"}
          {@muted_style}
        />
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-path-mixed"
          content={"Mixed: #{Map.get(@path_counts, :mixed, 0)}"}
          {@muted_style}
        />
      </div>
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
      |> Map.put(:overview_path, overview_path(assigns.current_category))

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-content" gap="lg" {@stack_style}>
      <LiveUi.Widgets.Box.render id="live-ui-demo-example-header" padding="lg" border="subtle" background="panel" {@panel_style}>
        <%= nav_link(
          "live-ui-demo-example-home",
          "Back To Overview",
          @overview_path,
          @home_button_style
        ) %>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-example-path"
          content={"#{String.upcase(to_string(@example.path))} example"}
          {@muted_style}
        />
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
      |> Map.put(:current_lane, Enum.find(assigns.categories, &(&1.id == assigns.current_category)))

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
