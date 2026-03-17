defmodule UnifiedExamples.Demo.Categories.FormsAndInput do
  @moduledoc """
  Forms and input gallery for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()
  @example_directories [
    "form_builder",
    "field_group",
    "field",
    "text_input",
    "numeric_input",
    "checkbox",
    "radio_group",
    "select",
    "pick_list",
    "date_input",
    "time_input",
    "file_input",
    "toggle"
  ]

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  identity do
    id(:forms_and_input)
    title("Forms and Input")
    description("Structured data entry, field composition, and input-focused review flows.")
    authored_ref([:examples, :demo, :categories, :forms_and_input])
    tags([:example, :demo, :category_fragment, :forms_and_input])
  end

  shared_theme_definition()

  composition do
    root(:forms_and_input_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Forms and input gallery")

    box :forms_gallery_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :forms_gallery_title do
        value("Forms and Input Gallery")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :forms_gallery_summary do
        value("Compare the shared input treatment across one complete authored form workflow.")
        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      text :forms_gallery_note do
        value(
          "Every representative control stays inside one coherent form so reviewers can compare input density and hierarchy quickly."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end

    form_builder :forms_gallery_form do
      summary("Representative forms and input workflow")
      submit_intent(:submit_gallery_form)
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      field_group :identity_inputs do
        legend("Primary inputs")

        field :display_name do
          field_name(:display_name)
          label("Display name")
          value_path([:draft, :display_name])

          text_input :display_name_input do
            placeholder("Add a reviewer-facing name")
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :quantity do
          field_name(:quantity)
          label("Quantity")

          numeric_input :quantity_input do
            placeholder("0")
            min(0)
            max(100)
            step(5)
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :subscribed do
          field_name(:subscribed)
          label("Subscribed")

          checkbox :subscribed_input do
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :role do
          field_name(:role)
          label("Role")

          radio_group :role_input do
            options(owner: "Owner", editor: "Editor")
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :labels do
          field_name(:labels)
          label("Labels")

          pick_list :labels_input do
            options(alpha: "Alpha", beta: "Beta", gamma: "Gamma")
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :publish_on do
          field_name(:publish_on)
          label("Publish on")

          date_input :publish_on_input do
            min("2026-01-01")
            max("2026-12-31")
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :publish_at do
          field_name(:publish_at)
          label("Publish at")

          time_input :publish_at_input do
            min("08:00")
            max("18:00")
            step(900)
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end

        field :attachment do
          field_name(:attachment)
          label("Attachment")

          file_input :attachment_input do
            accept(["image/png", "image/jpeg"])
            multiple?(true)
            capture("environment")
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:panel)
          end
        end
      end

      field :region do
        field_name(:region)
        label("Region")

        select :region_input do
          options(us: "United States", eu: "Europe")
          theme_ref(@default_theme_id)
          style_refs([:example_primary_input])
          tone(:surface)
          variant(:panel)
        end
      end

      field :enabled do
        field_name(:enabled)
        label("Enabled")

        toggle :enabled_input do
          theme_ref(@default_theme_id)
          style_refs([:example_primary_input])
          tone(:surface)
          variant(:panel)
        end
      end
    end
  end
end
