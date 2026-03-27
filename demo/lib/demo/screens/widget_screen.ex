defmodule Demo.Screens.WidgetScreen do
  @moduledoc """
  Generic widget demo screen.

  This screen displays a demo for a specific widget based on the
  widget_id passed in the params.
  """

  alias DesktopUi.Widgets
  alias Demo.Screens

  def render(assigns) do
    widget_id = Map.get(assigns, :widget_id)

    case widget_id do
      nil -> render_not_found(assigns)
      id -> render_widget_demo(id, assigns)
    end
  end

  defp render_not_found(_assigns) do
    Widgets.column("not-found", [
      Widgets.content("not-found-header", [
        Widgets.text("not-found-title", "Widget Not Found"),
        Widgets.text("not-found-desc", "The requested widget demo could not be found.")
      ]),
      Widgets.button("go-home", "Back to Home",
        navigate_to: :home
      )
    ])
  end

  defp render_widget_demo(widget_id, assigns) do
    Widgets.column("widget-demo-#{widget_id}", [
      # Header with widget info
      build_header(widget_id),
      Widgets.separator("widget-sep-1"),
      # Widget demo content
      build_widget_demo(widget_id)
    ])
  end

  defp build_header(widget_id) do
    {title, category} = get_widget_info(widget_id)

    Widgets.content("widget-header", [
      Widgets.breadcrumbs("widget-breadcrumbs", [
        %{id: :home, label: "Home"},
        %{id: category, label: category_name(category)},
        %{id: widget_id, label: title}
      ]),
      Widgets.text("widget-title", title),
      Widgets.text("widget-category", "Category: #{category_name(category)}")
    ])
  end

  defp build_widget_demo(widget_id) do
    Widgets.content("widget-content", [
      build_widget_examples(widget_id)
    ])
  end

  # Widget-specific demo builders

  defp build_widget_examples(:button) do
    Widgets.column("button-examples", [
      Widgets.text("examples-title", "Button Variants"),
      Widgets.row("button-variants", [
        Widgets.button("btn-primary", "Primary", variant: :primary),
        Widgets.button("btn-secondary", "Secondary", variant: :secondary),
        Widgets.button("btn-ghost", "Ghost", variant: :ghost)
      ]),
      Widgets.separator("btn-sep-1"),
      Widgets.text("sizes-title", "Button Sizes"),
      Widgets.row("button-sizes", [
        Widgets.button("btn-small", "Small", size: :sm),
        Widgets.button("btn-medium", "Medium", size: :md),
        Widgets.button("btn-large", "Large", size: :lg)
      ])
    ])
  end

  defp build_widget_examples(:text) do
    Widgets.column("text-examples", [
      Widgets.text("examples-title", "Text Typography"),
      Widgets.text("text-headline", "Headline Text", variant: :headline),
      Widgets.text("text-title", "Title Text", variant: :title),
      Widgets.text("text-body", "Body text with regular styling for reading."),
      Widgets.text("text-muted", "Muted text for secondary information", tone: :muted),
      Widgets.text("text-code", "Code text with monospace font", variant: :code)
    ])
  end

  defp build_widget_examples(:icon) do
    Widgets.column("icon-examples", [
      Widgets.text("examples-title", "Common Icons"),
      Widgets.row("icon-examples", [
        Widgets.icon("icon-home", :home),
        Widgets.icon("icon-settings", :settings),
        Widgets.icon("icon-search", :search),
        Widgets.icon("icon-folder", :folder),
        Widgets.icon("icon-file", :file),
        Widgets.icon("icon-tick", :tick),
        Widgets.icon("icon-cross", :cross),
        Widgets.icon("icon-warning", :warning)
      ])
    ])
  end

  defp build_widget_examples(:label) do
    Widgets.column("label-examples", [
      Widgets.text("examples-title", "Form Labels"),
      Widgets.row("label-row-1", [
        Widgets.label("label-1", "Username"),
        Widgets.label("label-2", "Email"),
        Widgets.label("label-3", "Password")
      ])
    ])
  end

  defp build_widget_examples(:link) do
    Widgets.column("link-examples", [
      Widgets.text("examples-title", "Navigation Links"),
      Widgets.link("link-home", "Go to Home", target: "/home"),
      Widgets.link("link-docs", "Documentation", target: "/docs"),
      Widgets.link("link-github", "GitHub Repo", target: "https://github.com")
    ])
  end

  defp build_widget_examples(:box) do
    Widgets.column("box-examples", [
      Widgets.text("examples-title", "Box Container"),
      Widgets.box("box-1", "Box with border", [
        Widgets.text("box-content", "Content inside a box")
      ], border: true)
    ])
  end

  defp build_widget_examples(:row) do
    Widgets.column("row-examples", [
      Widgets.text("examples-title", "Row Layout"),
      Widgets.row("row-1", [
        Widgets.button("row-btn-1", "Item 1"),
        Widgets.button("row-btn-2", "Item 2"),
        Widgets.button("row-btn-3", "Item 3")
      ])
    ])
  end

  defp build_widget_examples(:column) do
    Widgets.column("column-examples", [
      Widgets.text("examples-title", "Column Layout"),
      Widgets.row("column-row", [
        Widgets.column("col-1", [
          Widgets.button("col-btn-1", "Column 1"),
          Widgets.button("col-btn-2", "Column 1")
        ]),
        Widgets.column("col-2", [
          Widgets.button("col-btn-3", "Column 2"),
          Widgets.button("col-btn-4", "Column 2")
        ])
      ])
    ])
  end

  defp build_widget_examples(:grid) do
    Widgets.column("grid-examples", [
      Widgets.text("examples-title", "Grid Layout"),
      Widgets.grid("grid-1", [
        [
          Widgets.button("grid-btn-1", "1"),
          Widgets.button("grid-btn-2", "2"),
          Widgets.button("grid-btn-3", "3")
        ],
        [
          Widgets.button("grid-btn-4", "4"),
          Widgets.button("grid-btn-5", "5"),
          Widgets.button("grid-btn-6", "6")
        ]
      ])
    ])
  end

  defp build_widget_examples(:text_input) do
    Widgets.column("text-input-examples", [
      Widgets.text("examples-title", "Text Input Fields"),
      Widgets.text_input("input-1", "Enter text...", placeholder: "Placeholder text"),
      Widgets.separator("input-sep-1"),
      Widgets.text_input("input-2", "With default value", value: "Default text")
    ])
  end

  defp build_widget_examples(:checkbox) do
    Widgets.column("checkbox-examples", [
      Widgets.text("examples-title", "Checkboxes"),
      Widgets.checkbox("check-1", "Remember me", checked: true),
      Widgets.checkbox("check-2", "Accept terms"),
      Widgets.checkbox("check-3", "Subscribe to newsletter", checked: false)
    ])
  end

  defp build_widget_examples(:toggle) do
    Widgets.column("toggle-examples", [
      Widgets.text("examples-title", "Toggle Switches"),
      Widgets.toggle("toggle-1", "Dark mode", checked: true),
      Widgets.toggle("toggle-2", "Notifications"),
      Widgets.toggle("toggle-3", "Auto-update")
    ])
  end

  defp build_widget_examples(:menu) do
    Widgets.column("menu-examples", [
      Widgets.text("examples-title", "Menu Widget"),
      Widgets.menu("menu-1", [
        %{id: :file, label: "File"},
        %{id: :edit, label: "Edit"},
        %{id: :view, label: "View"}
      ])
    ])
  end

  defp build_widget_examples(:tabs) do
    Widgets.column("tabs-examples", [
      Widgets.text("examples-title", "Tabs Widget"),
      Widgets.tabs("tabs-1", [
        %{id: :tab1, label: "Tab 1"},
        %{id: :tab2, label: "Tab 2"},
        %{id: :tab3, label: "Tab 3"}
      ])
    ])
  end

  defp build_widget_examples(:list) do
    Widgets.column("list-examples", [
      Widgets.text("examples-title", "List Widget"),
      Widgets.list("list-1", [
        %{id: :item1, label: "Item 1"},
        %{id: :item2, label: "Item 2"},
        %{id: :item3, label: "Item 3"}
      ])
    ])
  end

  defp build_widget_examples(:table) do
    Widgets.column("table-examples", [
      Widgets.text("examples-title", "Table Widget"),
      Widgets.content("table-placeholder", [
        Widgets.text("table-note", "Table widget demo coming soon")
      ])
    ])
  end

  defp build_widget_examples(:status) do
    Widgets.column("status-examples", [
      Widgets.text("examples-title", "Status Indicators"),
      Widgets.row("status-row", [
        Widgets.status("status-success", "Success", status: :success),
        Widgets.status("status-info", "Info", status: :info),
        Widgets.status("status-warning", "Warning", status: :warning),
        Widgets.status("status-error", "Error", status: :error)
      ])
    ])
  end

  defp build_widget_examples(:progress) do
    Widgets.column("progress-examples", [
      Widgets.text("examples-title", "Progress Bars"),
      Widgets.progress("progress-1", label: "Progress", current: 25),
      Widgets.progress("progress-2", label: "Indeterminate", indeterminate: true)
    ])
  end

  defp build_widget_examples(_widget_id) do
    Widgets.content("widget-placeholder", [
      Widgets.text("placeholder-title", "Widget Demo"),
      Widgets.text("placeholder-desc", "Demo content for this widget is coming soon.")
    ])
  end

  # Helper functions

  defp get_widget_info(widget_id) do
    case Screens.screen_metadata(widget_id) do
      %{title: title} ->
        category = Map.get(Screens.screen_metadata(widget_id), :category)
        {title, category}

      _ ->
        {Atom.to_string(widget_id) |> String.capitalize(), nil}
    end
  end

  defp category_name(nil), do: "Uncategorized"
  defp category_name(category), do: Atom.to_string(category) |> String.capitalize()
end
