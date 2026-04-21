defmodule UnifiedExamples.ClusterDashboard.Helpers do
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
    mode: :shared_trigger,
    family: :command,
    source: :shared_trigger,
    widget: :cluster_dashboard,
    source_label: "Shared interaction trigger",
    trigger_label: "Inspect the cluster dashboard monitoring story",
    idle_prompt:
      "Use the shared trigger to see how the cluster dashboard example explains command changes for inspection, refresh, or focus flows.",
    outcome:
      "The review panel should explain how the cluster dashboard example turns an authored canonical interaction into a browser-visible operational story.",
    target_surface: "cluster dashboard review panel",
    reviewer_hint:
      "Reviewers should be able to understand the example outcome without opening source files or browser devtools."
  }

  @metadata %{
    id: :cluster_dashboard_example_screen,
    root_id: :cluster_dashboard_example_screen_root,
    title: "Cluster Dashboard Widget Example",
    summary: "Focused operational example using the local example shell",
    notes:
      "Cluster-dashboard examples foreground one canonical node-health summary inside the local shell.",
    widget: :cluster_dashboard,
    theme_id: @default_theme_id,
    interaction_demo: @interaction_demo
  }

  @severity :warning
  @metrics %{healthy: 2, degraded: 1, regions: 3}
  @cluster_nodes [
    %{id: "denver-a", status: :up},
    %{id: "dallas-b", status: :degraded},
    %{id: "atlanta-c", status: :up}
  ]

  @spec severity() :: atom()
  def severity, do: @severity

  @spec metrics() :: map()
  def metrics, do: @metrics

  @spec cluster_nodes() :: [map()]
  def cluster_nodes, do: @cluster_nodes

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

defmodule UnifiedExamples.ClusterDashboard.Theme do
  @moduledoc false

  alias UnifiedExamples.ClusterDashboard.Helpers

  @spec default_theme_id() :: atom()
  def default_theme_id, do: Helpers.default_theme_id()

  @spec summary() :: String.t()
  def summary, do: "Local default theme for the standalone example-app suite"

  @spec semantic_role_ids() :: [atom()]
  def semantic_role_ids, do: Helpers.semantic_role_ids()

  @spec token_ids() :: [atom()]
  def token_ids, do: Helpers.token_ids()
end

defmodule UnifiedExamples.ClusterDashboard.StyleProfile do
  @moduledoc false

  alias UnifiedExamples.ClusterDashboard.Helpers

  @spec default_style_profile() :: map()
  def default_style_profile, do: Helpers.style_profile()

  @spec browser_shell_classes() :: [String.t()]
  def browser_shell_classes, do: Helpers.browser_shell_classes()

  @spec component_style_ids() :: [atom()]
  def component_style_ids, do: Helpers.component_style_ids()
end

defmodule UnifiedExamples.ClusterDashboard.Screen do
  @moduledoc """
  Self-contained cluster-dashboard proof for the standalone example-app suite.
  """

  use UnifiedUi.Dsl

  alias UnifiedExamples.ClusterDashboard.Helpers
  alias UnifiedExamples.ClusterDashboard.StyleProfile
  alias UnifiedExamples.ClusterDashboard.Theme

  @spec example_metadata() :: map()
  def example_metadata, do: Helpers.metadata()

  @spec example_interaction_demo() :: map()
  def example_interaction_demo, do: example_metadata().interaction_demo

  @spec default_theme_id() :: atom()
  def default_theme_id, do: Theme.default_theme_id()

  @spec local_style_profile() :: map()
  def local_style_profile, do: StyleProfile.default_style_profile()

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: local_style_profile()

  identity do
    id(:cluster_dashboard_example_screen)
    title("Cluster Dashboard Widget Example")
    description("Focused operational example using the local example shell")
    authored_ref([:examples, :cluster_dashboard_example_screen])
    tags([:example, :cluster_dashboard])
  end

  signals do
    namespace(:examples)

    interaction do
      id(:cluster_dashboard_example_screen_interaction)
      family(:command)
      intent(:inspect_cluster_dashboard)

      source_context(
        element_id: :cluster_dashboard_example_screen_interaction_trigger,
        scope: :screen
      )

      target_intent(action: :review_example)

      payload_mapping(
        widget: :cluster_dashboard,
        example: :cluster_dashboard,
        outcome:
          "The review panel should explain how the cluster dashboard example turns an authored canonical interaction into a browser-visible operational story.",
        source: :shared_example_trigger
      )

      summary(
        "Use the shared trigger to see how the cluster dashboard example explains command changes for inspection, refresh, or focus flows."
      )
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
    root(:cluster_dashboard_example_screen_root)
    mode(:screen)
    summary("Self-contained example-app shell")

    box :cluster_dashboard_example_screen_shell do
      theme_ref(Theme.default_theme_id())
      style_refs([:example_shell])
      tone(:surface)
      variant(:panel)

      text :cluster_dashboard_example_screen_title do
        value("Cluster Dashboard Widget Example")
        theme_ref(Theme.default_theme_id())
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :cluster_dashboard_example_screen_summary do
        value("Focused operational example using the local example shell")
        theme_ref(Theme.default_theme_id())
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      box :cluster_dashboard_example_screen_panel do
        theme_ref(Theme.default_theme_id())
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)

        cluster_dashboard :cluster_dashboard_example_primary_cluster_dashboard do
          cluster_nodes(Helpers.cluster_nodes())
          metrics(Helpers.metrics())
          severity(Helpers.severity())
          theme_ref(Theme.default_theme_id())
          tone(:surface)
          variant(:quiet)
        end
      end

      button :cluster_dashboard_example_screen_interaction_trigger do
        label("Inspect the cluster dashboard monitoring story")
        interaction_refs([:cluster_dashboard_example_screen_interaction])
        theme_ref(Theme.default_theme_id())
        style_refs([:example_primary_button])
        tone(:accent)
        variant(:solid)
      end

      text :cluster_dashboard_example_screen_notes_text do
        value(
          "Cluster-dashboard examples foreground one canonical node-health summary inside the local shell."
        )

        theme_ref(Theme.default_theme_id())
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end
  end
end
