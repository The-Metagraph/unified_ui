defmodule UnifiedExamples.Demo.Categories.LayoutAndDisplay do
  @moduledoc """
  Layout and display gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()
  @example_directories [
    "box",
    "row",
    "column",
    "grid",
    "viewport",
    "scroll_bar",
    "split_pane",
    "canvas"
  ]

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:layout_and_display)
    title("Layout and Display")
    description("Spatial composition, display primitives, and container-oriented layout review.")
    authored_ref([:examples, :demo, :categories, :layout_and_display])
    tags([:example, :demo, :category_fragment, :layout_and_display])
  end

  shared_theme_definition()

  composition do
    root(:layout_and_display_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Layout and display gallery")

    box :layout_gallery_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :layout_gallery_title do
        value("Layout and Display Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :layout_gallery_summary do
        value(
          "Compare the core composition primitives and display systems under one shared review shell."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end
    end

    box :layout_display_box_demo do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :layout_display_box_title do
        value("Box container")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :layout_display_box_copy do
        value("Use boxes to frame one reviewable cluster without introducing extra navigation.")
        theme_ref(@default_theme_id)
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end

    row :layout_display_row_demo do
      gap(:md)
      justify(:space_between)

      text :layout_display_row_left do
        value("Row left")
      end

      text :layout_display_row_right do
        value("Row right")
      end
    end

    column :layout_display_column_demo do
      gap(:sm)

      text :layout_display_column_top do
        value("Column top")
      end

      text :layout_display_column_bottom do
        value("Column bottom")
      end
    end

    grid :layout_display_grid_demo do
      columns(2)
      gap(:sm)

      text :layout_display_grid_one do
        value("Grid A")
      end

      text :layout_display_grid_two do
        value("Grid B")
      end

      text :layout_display_grid_three do
        value("Grid C")
      end

      text :layout_display_grid_four do
        value("Grid D")
      end
    end

    box :layout_display_viewport_source do
      text :layout_display_viewport_copy do
        value("Viewport content for scroll review")
      end
    end

    viewport :layout_display_viewport do
      content_ref(:layout_display_viewport_source)
      width(48)
      height(8)
      offset({0, 2})
      clip?(true)
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)
    end

    scroll_bar :layout_display_scroll do
      target_ref(:layout_display_viewport)
      position(2)
      viewport_size(8)
      content_size(24)
      theme_ref(@default_theme_id)
      tone(:muted)
      variant(:solid)
    end

    box :layout_display_split_primary do
      text :layout_display_split_primary_copy do
        value("Split primary review region")
      end
    end

    box :layout_display_split_secondary do
      text :layout_display_split_secondary_copy do
        value("Split secondary review region")
      end
    end

    split_pane :layout_display_split do
      primary_ref(:layout_display_split_primary)
      secondary_ref(:layout_display_split_secondary)
      ratio(0.5)
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)
    end

    canvas :layout_display_canvas do
      width(18)
      height(6)

      operations([
        [kind: :cell, position: {0, 0}, text: "L"],
        [kind: :text, position: {2, 1}, text: "Layout"],
        [kind: :rect, position: {1, 3}, width: 8, height: 2]
      ])

      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)
    end
  end
end
