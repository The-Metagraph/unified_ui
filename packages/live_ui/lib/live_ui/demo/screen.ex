defmodule LiveUi.Demo.Screen do
  @moduledoc """
  Package-local demo screen that turns the `live_ui` example catalog into a
  navigable workbench.
  """

  use LiveUi.Screen, id: :live_ui_demo, title: "Live UI Demo"

  alias LiveUi.Demo
  alias LiveUi.Demo.{Catalog, Style, WidgetPreview}

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
      |> Map.put(:current_category_info, Catalog.category_info(current_category))
      |> Map.put(:selected_example_metadata, selected_example)
      |> Map.put(:preview, preview_for(selected_example))
      |> Map.put(:categories, Enum.map(Catalog.categories(), &Catalog.category_info/1))
      |> Map.put(:sidebar_examples, Catalog.category_examples(current_category))
      |> Map.put(:shell_style, Style.shell())
      |> Map.put(:stack_style, Style.layout(:column, "live-ui-demo-stack"))
      |> Map.put(:row_style, Style.layout(:row, "live-ui-demo-row"))

    ~H"""
    <LiveUi.Widgets.ScreenShell.render id="live-ui-demo" title="" {@shell_style}>
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
        "Package-local `live_ui` workbench for widget categories and package-owned widget inventory."
    }
  end

  defp browser_header(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-browser-header"))
      |> Map.put(:kicker_style, Style.text("live-ui-demo-browser-kicker", tone: :accent))
      |> Map.put(:title_style, Style.text("live-ui-demo-browser-title", tone: :success))
      |> Map.put(:summary_style, Style.text("live-ui-demo-browser-summary"))
      |> Map.put(:header_top_style, Style.layout(:row, "live-ui-demo-browser-header-top"))
      |> Map.put(:header_copy_style, Style.layout(:column, "live-ui-demo-browser-copy"))

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
          <LiveUi.Widgets.Text.render
            id="live-ui-demo-browser-summary"
            content={
              "Browse the package-local demo through the same server-authoritative runtime the package exposes everywhere else."
            }
            {@summary_style}
          />
        </LiveUi.Layout.Column.render>
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
        content="Explore Categories"
        {@muted_style}
      />

      <div class="live-ui-demo-sidebar-group live-ui-demo-sidebar-categories">
        <%= for category <- @categories do %>
          <%= category_button(assigns, category) %>
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

  defp content(%{view: :example, selected_example_metadata: %{path: :widget}} = assigns) do
    example = assigns.selected_example_metadata

    assigns =
      assigns
      |> Map.put(:example, example)
      |> Map.put(:panel_style, Style.panel("live-ui-demo-content"))
      |> Map.put(:metadata_panel_style, Style.panel("live-ui-demo-example-metadata"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-content-copy"))
      |> Map.put(:title_style, Style.text("live-ui-demo-content-title", tone: :accent))
      |> Map.put(
        :category_metadata,
        "Category: #{category_title(example.primary_category)} | Widget family: #{category_title(List.first(example.families))}"
      )

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-content" gap="lg" {@stack_style}>
      <%= category_examples_tabs(assigns) %>

      <LiveUi.Widgets.Box.render id="live-ui-demo-example-header" padding="lg" border="subtle" background="panel" {@panel_style}>
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
      </LiveUi.Widgets.Box.render>

      <WidgetPreview.render
        example={@example}
        demo_state={@widget_demo_state}
        event_target={@event_target}
      />

      <LiveUi.Widgets.Box.render
        id="live-ui-demo-example-metadata"
        padding="lg"
        border="subtle"
        background="panel"
        {@metadata_panel_style}
      >
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-example-categories"
          content={@category_metadata}
          {@muted_style}
        />
      </LiveUi.Widgets.Box.render>
    </LiveUi.Layout.Column.render>
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
      |> Map.put(:example_path_label, String.capitalize(to_string(example.path)))
      |> Map.put(:families_label, Enum.map_join(example.families, ", ", &category_title/1))

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-content" gap="lg" {@stack_style}>
      <%= category_examples_tabs(assigns) %>

      <LiveUi.Widgets.Box.render
        id="live-ui-demo-example-header"
        padding="lg"
        border="subtle"
        background="panel"
        {@panel_style}
      >
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
          content={"Maintained example: #{@example_path_label} | Families: #{@families_label}"}
          {@muted_style}
        />
      </LiveUi.Widgets.Box.render>

      <%= preview_panel(assigns) %>
      <%= browser_style_panel(assigns) %>
    </LiveUi.Layout.Column.render>
    """
  end

  defp content(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-home-panel"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-home-copy"))

    ~H"""
    <LiveUi.Layout.Column.render id="live-ui-demo-home" gap="lg" {@stack_style}>
      <%= category_examples_tabs(assigns) %>

      <LiveUi.Widgets.Box.render id="live-ui-demo-category-summary" padding="lg" border="subtle" background="panel" {@panel_style}>
        <LiveUi.Widgets.Text.render
          id="live-ui-demo-category-summary-copy"
          content={@current_category_info.description}
          {@muted_style}
        />
      </LiveUi.Widgets.Box.render>
    </LiveUi.Layout.Column.render>
    """
  end

  defp category_examples_tabs(assigns) do
    assigns =
      assigns
      |> Map.put(:panel_style, Style.panel("live-ui-demo-category-tabs-panel"))
      |> Map.put(:title_style, Style.text("live-ui-demo-category-tabs-title", tone: :accent))
      |> Map.put(:category_title, "Current category: #{assigns.current_category_info.title}")
      |> Map.put(
        :tabs_items,
        category_tab_items(assigns.sidebar_examples, assigns.current_category)
      )
      |> Map.put(:active_tab, active_category_tab(assigns.selected_example_metadata))

    ~H"""
    <LiveUi.Widgets.Box.render
      id="live-ui-demo-category-tabs-panel"
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-category-tabs-title"
        content={@category_title}
        {@title_style}
      />

      <LiveUi.Widgets.Tabs.render
        id="live-ui-demo-category-tabs"
        items={@tabs_items}
        active_item={@active_tab}
        class="live-ui-demo-category-tabs"
      />
    </LiveUi.Widgets.Box.render>
    """
  end

  defp category_tab_items(examples, current_category) do
    Enum.map(examples, fn example ->
      %{
        id: to_string(example.id),
        label: example.title,
        patch: example_path(example.id, current_category)
      }
    end)
  end

  defp active_category_tab(nil), do: nil
  defp active_category_tab(example), do: to_string(example.id)

  defp preview_panel(%{preview: %{mode: :html} = preview} = assigns) do
    assigns =
      assigns
      |> Map.put(:preview_data, preview)
      |> Map.put(:panel_style, Style.panel("live-ui-demo-preview"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-preview-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render
      id="live-ui-demo-preview"
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
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
      |> Map.put(:panel_style, Style.panel("live-ui-demo-preview"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-preview-copy"))

    ~H"""
    <LiveUi.Widgets.Box.render
      id="live-ui-demo-preview-report"
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-preview-report-title"
        content="Comparison Report"
        {@muted_style}
      />
      <pre><%= @preview_data.report %></pre>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp preview_panel(_assigns), do: nil

  defp browser_style_panel(%{preview: %{browser_style: browser_style} = preview} = assigns) do
    assigns =
      assigns
      |> Map.put(:browser_style, browser_style)
      |> Map.put(:style_nodes, Enum.take(Map.get(preview, :browser_style_nodes, []), 4))
      |> Map.put(:panel_style, Style.panel("live-ui-demo-browser-style"))
      |> Map.put(:muted_style, Style.text("live-ui-demo-browser-style-copy"))
      |> Map.put(:title_style, Style.text("live-ui-demo-browser-style-title", tone: :success))

    ~H"""
    <LiveUi.Widgets.Box.render
      id="live-ui-demo-browser-style"
      padding="lg"
      border="subtle"
      background="panel"
      {@panel_style}
    >
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-title"
        content="Browser Style Surface"
        {@title_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-modes"
        content={"Modes: " <> Enum.join(@browser_style.modes, ", ")}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-realized"
        content={"Realized fields: " <> Enum.join(@browser_style.realized_fields, ", ")}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-css-vars"
        content={"CSS vars: " <> Enum.join(@browser_style.css_var_keys, ", ")}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-unsupported"
        content={"Unsupported fields: " <> empty_label(@browser_style.unsupported_fields)}
        {@muted_style}
      />
      <LiveUi.Widgets.Text.render
        id="live-ui-demo-browser-style-ignored"
        content={"Ignored fields: " <> empty_label(@browser_style.ignored_fields)}
        {@muted_style}
      />

      <%= for node <- @style_nodes do %>
        <LiveUi.Widgets.Text.render
          id={"live-ui-demo-browser-style-node-#{node.id}"}
          content={"Browser style nodes: #{node.id} -> " <> Enum.join(node.css_var_keys, ", ")}
          {@muted_style}
        />
      <% end %>
    </LiveUi.Widgets.Box.render>
    """
  end

  defp browser_style_panel(_assigns), do: nil

  defp preview_for(nil), do: nil

  defp preview_for(example) do
    case Catalog.preview(example.id) do
      {:ok, preview} -> preview
      {:error, reason} -> %{mode: :error, reason: reason}
    end
  end

  defp category_title(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp example_path(example, category) do
    Demo.path(example: example, category: category)
  end

  defp category_path(category) do
    Demo.path(category: category)
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

  defp empty_label([]), do: "none"
  defp empty_label(values), do: Enum.join(values, ", ")
end
