defmodule UnifiedUi.Dsl.Entities.Styles do
  @moduledoc """
  Spark DSL Entity definitions for named styles.

  This module defines the style entity for creating reusable, named styles
  that can be referenced by widgets and layouts.

  ## Usage

  Styles are defined in the `styles` section of a UI module:

      defmodule MyApp.MyScreen do
        use UnifiedUi.Dsl

        styles do
          style :header do
            attributes [
              fg: :cyan,
              attrs: [:bold],
              padding: 1
            ]
          end

          style :error_header do
            extends :header
            attributes [
              fg: :red,
              attrs: [:bold, :underline]
            ]
          end
        end

        ui do
          vbox do
            text "Welcome", style: :header
            text "Error!", style: :error_header
          end
        end
      end

  ## Style Inheritance

  Styles can extend other styles using the `extends` option. The child style
  inherits all attributes from the parent and can override them:

      style :button_base do
        attributes [
          padding: 1,
          attrs: [:bold]
        ]
      end

      style :primary_button do
        extends :button_base
        attributes [
          fg: :white,
          bg: :blue
        ]
      end

  ## Combining with Inline Styles

  Named styles can be combined with inline styles. Inline styles take
  precedence:

      text "Title", style: [:header, fg: :green]
      # This would use all header attributes but override fg to :green

  """

  alias UnifiedUi.Dsl.Style
  alias UnifiedUi.Dsl.Theme

  @style_entity %Spark.Dsl.Entity{
    name: :style,
    target: Style,
    args: [:name],
    schema: [
      name: [
        type: :atom,
        doc: "Unique name for this style.",
        required: true
      ],
      extends: [
        type: :atom,
        doc: """
        Optional parent style name to inherit from.

        The child style will inherit all attributes from the parent style.
        Attributes specified in the child style override parent attributes.
        """,
        required: false
      ],
      attributes: [
        type: :keyword_list,
        doc: """
        Style attributes as a keyword list.

        Valid attributes include:
        * `:fg` - Foreground color (atom, RGB tuple, or hex string)
        * `:bg` - Background color (atom, RGB tuple, or hex string)
        * `:attrs` - Text attributes list (:bold, :italic, :underline, :reverse)
        * `:padding` - Internal spacing (integer)
        * `:margin` - External spacing (integer)
        * `:width` - Width constraint (integer, :auto, or :fill)
        * `:height` - Height constraint (integer, :auto, or :fill)
        * `:align` - Alignment (:left, :center, :right, :top, :bottom, etc.)
        * `:spacing` - Spacing between children for layouts (integer)
        * `:font_family` - Font family (string)
        * `:font_size` - Font size (integer px or CSS size string)
        * `:font_weight` - Font weight (:normal, :bold, :bolder, :lighter, or integer)
        * `:border` - Border shorthand (string/integer) or descriptor map/keyword
        * `:border_width` - Border width (integer)
        * `:border_color` - Border color (atom, RGB tuple, or hex string)
        * `:border_style` - Border style (:none, :solid, :dashed, :dotted, :double)
        """,
        required: false,
        default: []
      ]
    ],
    describe: """
    A named style that can be referenced by widgets and layouts.

    Styles support inheritance through the `extends` option, allowing
    you to create style hierarchies and variants.
    """
  }

  @theme_entity %Spark.Dsl.Entity{
    name: :theme,
    target: Theme,
    args: [:name],
    schema: [
      name: [
        type: :atom,
        doc: "Unique name for this theme.",
        required: true
      ],
      styles: [
        type: :keyword_list,
        doc: """
        Theme style mappings as a keyword list.

        Each key is a theme-specific style token (for example `:primary_button`)
        and each value is any valid style reference:
        * named style atom
        * inline style keyword list
        * named style with inline overrides (list starting with atom)
        """,
        required: false,
        default: []
      ],
      base_theme: [
        type: :atom,
        doc: """
        Optional parent theme name.

        When present, this theme inherits all style mappings from the base theme.
        Local mappings override inherited keys.
        """,
        required: false
      ]
    ],
    describe: """
    A named theme that groups style references under semantic keys.

    Themes can inherit from other themes using `base_theme`.
    """
  }

  @doc false
  @spec style_entity() :: Spark.Dsl.Entity.t()
  def style_entity, do: @style_entity

  @doc false
  @spec theme_entity() :: Spark.Dsl.Entity.t()
  def theme_entity, do: @theme_entity
end
