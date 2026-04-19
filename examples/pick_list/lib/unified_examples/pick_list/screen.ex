defmodule UnifiedExamples.PickList.Screen do
  @moduledoc """
  Self-contained pick_list proof for the standalone example-app suite.
  """

  use UnifiedUi.Dsl

  alias UnifiedExamples.PickList.Helpers
  alias UnifiedExamples.PickList.StyleProfile
  alias UnifiedExamples.PickList.Theme

  @example_metadata Helpers.metadata()

  @spec example_metadata() :: map()
  def example_metadata, do: @example_metadata

  @spec example_interaction_demo() :: map()
  def example_interaction_demo, do: @example_metadata.interaction_demo

  @spec default_theme_id() :: atom()
  def default_theme_id, do: Theme.default_theme_id()

  @spec local_style_profile() :: map()
  def local_style_profile, do: StyleProfile.default_style_profile()

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: local_style_profile()

  identity do
    id(:pick_list_example_screen)
    title("Pick List Widget Example")
    description("Focused input-oriented example using the local example shell")
    authored_ref([:examples, :pick_list_example_screen])
    tags([:example, :pick_list])
  end

  signals do
    namespace(:examples)

    interaction do
      id(:pick_list_example_screen_interaction)
      family(:selection)
      intent(:inspect_pick_list)

      source_context(
        element_id: :pick_list_example_screen_shell,
        scope: :screen
      )

      target_intent(action: :review_example)

      payload_mapping(
        widget: :pick_list,
        example: :pick_list,
        outcome: "The review panel should explain how the pick list example turns live form input into a browser-visible selection outcome.",
        source: :shared_form_shell
      )

      summary("Interact with the pick list example to see how its authored selection signal updates the shared review story.")
    end
  end

  themes do
    default_theme(Theme.default_theme_id())

    theme do
      id(Theme.default_theme_id())
      summary(Theme.summary())

      palette_color do
        id(:surface)
        color(rgb_color(18, 18, 18))
      end

      palette_color do
        id(:accent)
        color(rgb_color(0, 255, 136))
      end

      palette_color do
        id(:success)
        color(rgb_color(0, 255, 136))
      end

      palette_color do
        id(:warning)
        color(rgb_color(255, 184, 0))
      end

      palette_color do
        id(:critical)
        color(rgb_color(235, 123, 123))
      end

      palette_color do
        id(:muted)
        color(rgb_color(102, 102, 102))
      end

      semantic_role do
        id(:surface)
        value(rgb_color(18, 18, 18))
      end

      semantic_role do
        id(:accent)
        value(rgb_color(0, 255, 136))
      end

      semantic_role do
        id(:success)
        value(rgb_color(0, 255, 136))
      end

      semantic_role do
        id(:warning)
        value(rgb_color(255, 184, 0))
      end

      semantic_role do
        id(:critical)
        value(rgb_color(235, 123, 123))
      end

      semantic_role do
        id(:muted)
        value(rgb_color(102, 102, 102))
      end

      semantic_role do
        id(:foreground)
        value(rgb_color(232, 232, 232))
      end

      token do
        id(:shell_surface)

        value(
          style_value(
            background: token_ref(:surface),
            foreground: role_ref(:foreground),
            spacing: %{padding: 2, gap: 1},
            border: %{width: 1, style: :solid}
          )
        )
      end

      token do
        id(:panel_surface)

        value(
          style_value(
            background: token_ref(:surface),
            foreground: role_ref(:foreground),
            spacing: %{padding: 2, gap: 1},
            border: %{width: 1, style: :solid}
          )
        )
      end

      token do
        id(:accent_action)

        value(
          style_value(
            background: role_ref(:accent),
            foreground: rgb_color(10, 10, 10),
            border_color: role_ref(:accent),
            emphasis: %{tone: :accent}
          )
        )
      end

      token do
        id(:input_surface)

        value(
          style_value(
            background: token_ref(:surface),
            foreground: role_ref(:foreground),
            border_color: role_ref(:muted)
          )
        )
      end

      component_style do
        id(:example_shell)
        component(:box)
        variant(:panel)

        style(
          style_value(
            token_refs: [token_ref(:shell_surface)],
            sizing: %{width: :fill},
            alignment: %{align: :stretch}
          )
        )
      end

      component_style do
        id(:example_panel)
        component(:box)
        variant(:panel)

        style(
          style_value(
            token_refs: [token_ref(:panel_surface)],
            emphasis: %{tone: :surface}
          )
        )
      end

      component_style do
        id(:example_form_shell)
        component(:form_builder)
        variant(:panel)

        style(
          style_value(
            token_refs: [token_ref(:panel_surface)],
            emphasis: %{tone: :surface}
          )
        )
      end

      component_style do
        id(:example_title)
        component(:text)
        variant(:headline)

        style(
          style_value(
            foreground: role_ref(:accent),
            emphasis: %{weight: :strong}
          )
        )
      end

      component_style do
        id(:example_summary)
        component(:text)
        variant(:body)

        style(style_value(foreground: role_ref(:muted)))
      end

      component_style do
        id(:example_notes)
        component(:text)
        variant(:body)

        style(style_value(foreground: role_ref(:muted)))
      end

      component_style do
        id(:example_primary_button)
        component(:button)
        variant(:solid)

        style(style_value(token_refs: [token_ref(:accent_action)]))
      end

      component_style do
        id(:example_primary_input)
        component(:text_input)
        variant(:filled)

        style(style_value(token_refs: [token_ref(:input_surface)]))
      end
    end
  end

  composition do
    root(:pick_list_example_screen_root)
    mode(:screen)
    summary("Self-contained form-oriented example-app shell")

    form_builder :pick_list_example_screen_shell do
      summary("Self-contained form-oriented example-app shell")
      theme_ref(Theme.default_theme_id())
      style_refs([:example_form_shell])
      tone(:surface)
      variant(:panel)
      interaction_refs([:pick_list_example_screen_interaction])

      text :pick_list_example_screen_title do
        value("Pick List Widget Example")
        theme_ref(Theme.default_theme_id())
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :pick_list_example_screen_summary do
        value("Focused input-oriented example using the local example shell")
        theme_ref(Theme.default_theme_id())
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      spacer :pick_list_example_screen_form_gap do
        size(:sm)
      end

      field :pick_list_example_primary_field do
        field_name(:labels)
        label("Labels")

        pick_list :pick_list_example_primary_input do
          options(alpha: "Alpha", beta: "Beta", gamma: "Gamma")
          multiple?(true)
          theme_ref(Theme.default_theme_id())
          style_refs([:example_primary_input])
          tone(:surface)
          variant(:filled)
        end
      end


      text :pick_list_example_screen_notes_text do
        value("Pick list examples keep the local form shell while foregrounding one multi-select control.")
        theme_ref(Theme.default_theme_id())
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end
  end
end

defmodule UnifiedExamples.PickList.Helpers do
  @moduledoc false

  @default_theme_id :example_suite_default

  @browser_shell_classes [
    "example-app-shell",
    "example-app-header",
    "example-app-runtime",
    "example-app-header-top",
    "example-app-kicker",
    "example-app-widget",
    "example-app-title",
    "example-app-summary",
    "example-app-notes"
  ]

  @component_style_ids [
    :example_shell,
    :example_panel,
    :example_form_shell,
    :example_title,
    :example_summary,
    :example_notes,
    :example_primary_button,
    :example_primary_input
  ]

  @semantic_role_ids [
    :surface,
    :accent,
    :success,
    :warning,
    :critical,
    :muted,
    :foreground
  ]

  @token_ids [
    :shell_surface,
    :panel_surface,
    :accent_action,
    :input_surface
  ]

  @style_profile %{
    shell: [:example_shell],
    panel: [:example_panel],
    form_shell: [:example_form_shell],
    title: [:example_title],
    summary: [:example_summary],
    notes: [:example_notes],
    interaction_button: [:example_primary_button],
    button: [:example_primary_button],
    text_input: [:example_primary_input]
  }

  @interaction_demo %{
    mode: :form_shell,
    family: :selection,
    source: :form_shell,
    widget: :pick_list,
    source_label: "Shared form shell",
    trigger_label: nil,
    idle_prompt: "Interact with the pick list example to see how its authored selection signal updates the shared review story.",
    outcome: "The review panel should explain how the pick list example turns live form input into a browser-visible selection outcome.",
    target_surface: "pick_list review panel",
    reviewer_hint:
      "Reviewers should be able to understand the example outcome without opening source files or browser devtools."
  }

  @metadata %{
    id: :pick_list_example_screen,
    root_id: :pick_list_example_screen_root,
    title: "Pick List Widget Example",
    summary: "Focused input-oriented example using the local example shell",
    notes: "Pick list examples keep the local form shell while foregrounding one multi-select control.",
    widget: :pick_list,
    theme_id: @default_theme_id,
    interaction_demo: @interaction_demo
  }

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec browser_shell_classes() :: [String.t()]
  def browser_shell_classes, do: @browser_shell_classes

  @spec component_style_ids() :: [atom()]
  def component_style_ids, do: @component_style_ids

  @spec semantic_role_ids() :: [atom()]
  def semantic_role_ids, do: @semantic_role_ids

  @spec token_ids() :: [atom()]
  def token_ids, do: @token_ids

  @spec style_profile() :: map()
  def style_profile, do: @style_profile

  @spec metadata() :: map()
  def metadata, do: @metadata
end

defmodule UnifiedExamples.PickList.Theme do
  @moduledoc false

  alias UnifiedExamples.PickList.Helpers

  @spec default_theme_id() :: atom()
  def default_theme_id, do: Helpers.default_theme_id()

  @spec summary() :: String.t()
  def summary, do: "Local default theme for the standalone example-app suite"

  @spec semantic_role_ids() :: [atom()]
  def semantic_role_ids, do: Helpers.semantic_role_ids()

  @spec token_ids() :: [atom()]
  def token_ids, do: Helpers.token_ids()
end

defmodule UnifiedExamples.PickList.StyleProfile do
  @moduledoc false

  alias UnifiedExamples.PickList.Helpers

  @spec default_style_profile() :: map()
  def default_style_profile, do: Helpers.style_profile()

  @spec browser_shell_classes() :: [String.t()]
  def browser_shell_classes, do: Helpers.browser_shell_classes()

  @spec component_style_ids() :: [atom()]
  def component_style_ids, do: Helpers.component_style_ids()
end
