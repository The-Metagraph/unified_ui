defmodule UnifiedExamples.Demo.Categories.FoundationalContent do
  @moduledoc """
  Foundational content gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()
  @example_directories [
    "text",
    "label",
    "icon",
    "image",
    "button",
    "link",
    "separator",
    "spacer",
    "content"
  ]
  @category_metadata %{
    id: :foundational_content,
    title: "Foundational Content",
    summary: "Baseline copy, imagery, spacing, and primary action controls.",
    note:
      "Review how the shared theme baseline presents the core content controls before the denser data and interaction stories arrive.",
    root_id: :foundational_content_category_fragment_root
  }

  @spec category_metadata() :: map()
  def category_metadata, do: @category_metadata

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:foundational_content)
    title("Foundational Content")
    description("Baseline copy, imagery, spacing, and primary action controls.")
    authored_ref([:examples, :demo, :categories, :foundational_content])
    tags([:example, :demo, :category_fragment, :foundational_content])
  end

  shared_theme_definition()

  composition do
    root(:foundational_content_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Foundational content gallery")

    content :foundational_story_copy do
      summary("Shared story copy")
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :foundational_story_headline do
        value("Core copy remains readable first.")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      label :foundational_story_label do
        value("Trace the primary content cadence before deeper interaction stories.")
        target(:foundational_primary_action)
        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      icon :foundational_story_icon do
        name(:sparkles)
        set(:system)
        theme_ref(@default_theme_id)
        tone(:accent)
        variant(:solid)
      end
    end

    box :foundational_content_gallery_shell do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)
      summary("Foundational content gallery shell")

      text :foundational_content_gallery_title do
        value("Foundational Content Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :foundational_content_gallery_summary do
        value(
          "Review the baseline content controls together under the shared example-suite shell."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      grid :foundational_representative_grid do
        columns(2)
        gap(:md)

        box :foundational_media_card do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :foundational_media_card_title do
            value("Image and icon")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :foundational_media_card_copy do
            value(
              "Check that imagery and symbolic accents stay legible without breaking the shared shell."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          image :foundational_gallery_image do
            source("/demo/foundational.png")
            alt_text("Foundational gallery illustration")
            theme_ref(@default_theme_id)
            tone(:surface)
            variant(:panel)
          end
        end

        box :foundational_action_card do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :foundational_action_card_title do
            value("Primary action and link")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :foundational_action_card_copy do
            value(
              "The primary action and outbound link should feel like part of one coherent review flow."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          button :foundational_primary_action do
            label("Review shared CTA")
            action_intent(:review_foundational_cta)
            theme_ref(@default_theme_id)
            style_refs([:example_primary_button])
            tone(:accent)
            variant(:solid)
          end

          link :foundational_docs_link do
            label("Open shared guidelines")
            target("https://example.test/foundational-guidelines")
            external?(true)
            theme_ref(@default_theme_id)
            style_refs([:example_summary])
            tone(:accent)
            variant(:body)
          end
        end

        box :foundational_structure_card do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :foundational_structure_card_title do
            value("Separator and spacer")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :foundational_structure_card_copy do
            value(
              "Structural rhythm should remain obvious even when the review surface becomes denser."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          separator :foundational_separator do
            orientation(:horizontal)
            theme_ref(@default_theme_id)
            tone(:muted)
            variant(:solid)
          end

          spacer :foundational_gap do
            size(:lg)
            theme_ref(@default_theme_id)
            tone(:surface)
            variant(:panel)
          end
        end

        box :foundational_content_card do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :foundational_content_card_title do
            value("Content grouping")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :foundational_content_card_copy do
            value(
              "Nested content blocks should make grouping and narrative order obvious without extra chrome."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          box :foundational_content_group do
            summary("Grouped foundational content")
            theme_ref(@default_theme_id)
            style_refs([:example_panel])
            tone(:surface)
            variant(:panel)

            text :foundational_content_group_headline do
              value("Grouped content stays compact.")
              theme_ref(@default_theme_id)
              style_refs([:example_summary])
              tone(:muted)
              variant(:body)
            end

            label :foundational_content_group_label do
              value(
                "Use content groups when reviewers should scan a short narrative block as one surface."
              )

              target(:foundational_primary_action)
              theme_ref(@default_theme_id)
              style_refs([:example_notes])
              tone(:muted)
              variant(:body)
            end
          end
        end
      end
    end
  end
end
