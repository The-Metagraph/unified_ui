defmodule Demo.Widgets.Sidebar do
  @moduledoc """
  Navigation sidebar widget.

  Displays category buttons and a list of widgets in the selected category.
  """

  alias DesktopUi.Widgets
  alias Demo.Screens

  def build(id, opts \\ []) do
    current_category = Keyword.get(opts, :current_category, :content)
    current_widget = Keyword.get(opts, :current_widget)

    Widgets.column(id, [
      # Logo/title
      Widgets.content("sidebar-logo", [
        Widgets.icon("demo-icon", :application),
        Widgets.label("demo-label", "Desktop UI")
      ]),
      Widgets.separator("sidebar-logo-sep"),
      # Category buttons
      build_category_buttons(current_category),
      Widgets.separator("sidebar-categories-sep"),
      # Widget list for current category
      build_widget_list(current_category, current_widget)
    ], gap: 8)
  end

  defp build_category_buttons(current_category) do
    categories = [
      {:content, "Content", :content},
      {:layout, "Layout", :box},
      {:forms, "Forms", :form_builder},
      {:input, "Input", :text_input},
      {:navigation, "Navigation", :menu},
      {:data, "Data", :table},
      {:feedback, "Feedback", :status},
      {:display, "Display", :viewport},
      {:overlay, "Overlay", :dialog},
      {:operational, "Operational", :monitor}
    ]

    Widgets.column("category-buttons", Enum.map(categories, fn {id, label, icon} ->
      is_active = current_category == id

      Widgets.button("cat-#{id}", label,
        icon: icon,
        size: :sm,
        # Use widget helper for navigation
        navigate_to: id,
        navigate_params: %{category: id},
        styles: %{
          variant: if(is_active, do: :solid, else: :ghost),
          text_align: :left,
          width: :fill
        }
      )
    end))
  end

  defp build_widget_list(category, current_widget) do
    widgets = Screens.widgets_for_category(category)

    if widgets == [] do
      Widgets.content("no-widgets", [
        Widgets.text("no-widgets-text", "No widgets in this category", tone: :muted)
      ])
    else
      Widgets.column("widget-list", Enum.map(widgets, fn {widget_id, title, _desc} ->
        is_active = current_widget == widget_id

        Widgets.button("widget-#{widget_id}", title,
          icon: widget_id,
          size: :sm,
          navigate_to: widget_id,
          navigate_params: %{widget_id: widget_id, category: category},
          styles: %{
            variant: if(is_active, do: :solid, else: :ghost),
            text_align: :left,
            width: :fill
          }
        )
      end))
    end
  end
end
