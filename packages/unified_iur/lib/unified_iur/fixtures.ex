defmodule UnifiedIUR.Fixtures do
  @moduledoc """
  Maintained reference fixtures for the canonical `UnifiedIUR` surface.
  """

  alias UnifiedIUR.{
    Canvas,
    Binding,
    Collection,
    Container,
    Extension,
    Forms,
    Interaction,
    Interoperability,
    Layer,
    Layout
  }

  alias UnifiedIUR.Widgets.{
    Advanced,
    Data,
    Feedback,
    Foundational,
    Input,
    Navigation,
    Semantic,
    Workflow
  }

  @fixture_specs [
    %{
      id: "foundational--workspace_chrome",
      category: :foundational,
      description:
        "Foundational widgets, containers, and navigation assembled as a portable workspace chrome.",
      semantics: [
        "content and accessibility hooks",
        "foundational action and navigation widgets",
        "top-level navigation constructs"
      ],
      parity_obligations: [
        :foundational_widgets,
        :navigation_widgets,
        :container_constructs,
        :layout_constructs
      ],
      snapshot: "foundational--workspace_chrome.snapshot"
    },
    %{
      id: "forms--profile_editor",
      category: :forms,
      description:
        "Form composition with the full input surface, bindings, and submit interactions.",
      semantics: [
        "field composition and label relationships",
        "input binding coverage",
        "canonical submit interaction coverage"
      ],
      parity_obligations: [:input_widgets, :form_constructs],
      snapshot: "forms--profile_editor.snapshot"
    },
    %{
      id: "data--content_and_feedback",
      category: :data,
      description:
        "Data and feedback constructs rendered together as a review-friendly canonical dashboard.",
      semantics: [
        "list, table, and tree presentation",
        "status and progress semantics",
        "review-oriented content layout"
      ],
      parity_obligations: [
        :data_widgets,
        :feedback_widgets,
        :layout_constructs,
        :collection_constructs
      ],
      snapshot: "data--content_and_feedback.snapshot"
    },
    %{
      id: "portable_widgets--ash_ui_portability",
      category: :portable_widgets,
      description:
        "Portable semantic, workflow, document, composer, and repeated template widgets promoted from AshUi proposals.",
      semantics: [
        "portable semantic micro-widget coverage",
        "portable workflow and document widget coverage",
        "promoted widgets inside repeated collection templates"
      ],
      parity_obligations: [
        :semantic_widgets,
        :workflow_widgets,
        :collection_constructs,
        :layout_constructs
      ],
      snapshot: "portable_widgets--ash_ui_portability.snapshot"
    },
    %{
      id: "display--layered_workspace",
      category: :display,
      description:
        "Layered, scrollable, and split display-system constructs combined in one canonical workspace.",
      semantics: [
        "split and viewport display systems",
        "overlay and dialog layering",
        "cross-cutting theme attachments"
      ],
      parity_obligations: [:layout_constructs, :layer_constructs, :container_constructs],
      snapshot: "display--layered_workspace.snapshot"
    },
    %{
      id: "advanced--operations_center",
      category: :advanced,
      description:
        "Advanced operational widgets, charts, and canvas constructs arranged as an operations center.",
      semantics: [
        "operational and diagnostic widgets",
        "chart and canvas constructs",
        "command and inspection coverage"
      ],
      parity_obligations: [:advanced_widgets, :canvas_constructs, :feedback_widgets],
      snapshot: "advanced--operations_center.snapshot"
    }
  ]

  @navigation_fixture_specs [
    %{
      id: "screen_transition--settings_profile",
      description:
        "Canonical top-level screen transition targeting the settings screen with portable params.",
      semantics: [
        "screen transition action vocabulary",
        "symbolic screen identifiers",
        "portable params and payload mapping"
      ],
      snapshot: "fixtures/navigation/screen_transition--settings_profile.snapshot"
    },
    %{
      id: "replace_transition--home",
      description: "Canonical screen replacement that does not assume browser-route semantics.",
      semantics: [
        "replacement transition action vocabulary",
        "symbolic screen identifiers",
        "review-friendly replacement params"
      ],
      snapshot: "fixtures/navigation/replace_transition--home.snapshot"
    },
    %{
      id: "history_transition--back",
      description:
        "Canonical targetless history traversal using portable action meaning without fake screen ids.",
      semantics: [
        "targetless history traversal",
        "portable history transition meaning",
        "metadata without browser-history APIs"
      ],
      snapshot: "fixtures/navigation/history_transition--back.snapshot"
    },
    %{
      id: "modal_transition--settings_dialog",
      description:
        "Canonical modal transition carrying a symbolic modal target and portable params.",
      semantics: [
        "modal transition action vocabulary",
        "symbolic modal identifiers",
        "portable params and metadata"
      ],
      snapshot: "fixtures/navigation/modal_transition--settings_dialog.snapshot"
    }
  ]

  @spec ids() :: [String.t()]
  def ids do
    Enum.map(@fixture_specs, & &1.id)
  end

  @spec catalog() :: [map()]
  def catalog do
    Enum.map(@fixture_specs, &Map.put(&1, :snapshot_path, snapshot_name(&1.id)))
  end

  @spec categories() :: [atom()]
  def categories do
    @fixture_specs |> Enum.map(& &1.category) |> Enum.uniq()
  end

  @spec naming_rules() :: map()
  def naming_rules do
    %{
      fixture_id_pattern: "category--scenario",
      snapshot_suffix: ".snapshot",
      categories: categories()
    }
  end

  @spec fixture(String.t()) :: {:ok, map()} | :error
  def fixture(id) when is_binary(id) do
    case Enum.find(@fixture_specs, &(&1.id == id)) do
      nil ->
        :error

      spec ->
        {:ok,
         spec
         |> Map.put(:snapshot_path, snapshot_name(spec.id))
         |> Map.put(:element, build_fixture(spec.id))}
    end
  end

  @spec fixture!(String.t()) :: map()
  def fixture!(id) do
    case fixture(id) do
      {:ok, fixture} -> fixture
      :error -> raise ArgumentError, "unknown fixture #{inspect(id)}"
    end
  end

  @spec all() :: [map()]
  def all do
    Enum.map(ids(), &fixture!/1)
  end

  @spec coverage_report() :: map()
  def coverage_report do
    fixtures = all()

    covered_kinds =
      fixtures
      |> Enum.flat_map(fn fixture ->
        fixture.element
        |> Interoperability.walk()
        |> Enum.map(& &1.kind)
      end)
      |> Enum.uniq()

    categories =
      Extension.iur_catalog()
      |> Map.new(fn {category, expected} ->
        covered = Enum.filter(expected, &(&1 in covered_kinds))

        {category,
         %{
           expected: expected,
           covered: covered,
           missing: expected -- covered
         }}
      end)

    attachment_families =
      [
        style_semantics:
          attachment_family_report(fixtures, fn element ->
            match?(%UnifiedIUR.Style{}, Map.get(element.attributes, :style)) or
              theme_token_refs?(Map.get(element.attributes, :theme))
          end),
        theme_semantics:
          attachment_family_report(fixtures, fn element ->
            Map.has_key?(element.attributes, :theme)
          end),
        interaction_semantics:
          attachment_family_report(fixtures, fn element ->
            Map.has_key?(element.attributes, :interactions)
          end),
        binding_semantics:
          attachment_family_report(fixtures, fn element ->
            Map.has_key?(element.attributes, :bindings)
          end)
      ]
      |> Enum.into(%{})

    %{
      fixture_ids: ids(),
      covered_kinds: Enum.sort(covered_kinds),
      categories: categories,
      attachment_families: attachment_families,
      complete?: Enum.all?(categories, fn {_category, report} -> report.missing == [] end)
    }
  end

  @spec snapshot_name(String.t()) :: String.t()
  def snapshot_name(id) do
    "fixtures/#{id}.snapshot"
  end

  @spec navigation_ids() :: [String.t()]
  def navigation_ids do
    Enum.map(@navigation_fixture_specs, & &1.id)
  end

  @spec navigation_catalog() :: [map()]
  def navigation_catalog do
    Enum.map(
      @navigation_fixture_specs,
      &Map.put(&1, :snapshot_path, navigation_snapshot_name(&1.id))
    )
  end

  @spec navigation_fixture(String.t()) :: {:ok, map()} | :error
  def navigation_fixture(id) when is_binary(id) do
    case Enum.find(@navigation_fixture_specs, &(&1.id == id)) do
      nil ->
        :error

      spec ->
        {:ok,
         spec
         |> Map.put(:snapshot_path, navigation_snapshot_name(spec.id))
         |> Map.put(:interaction, build_navigation_fixture(spec.id))}
    end
  end

  @spec navigation_fixture!(String.t()) :: map()
  def navigation_fixture!(id) do
    case navigation_fixture(id) do
      {:ok, fixture} -> fixture
      :error -> raise ArgumentError, "unknown navigation fixture #{inspect(id)}"
    end
  end

  @spec navigation_snapshot_name(String.t()) :: String.t()
  def navigation_snapshot_name(id) do
    "fixtures/navigation/#{id}.snapshot"
  end

  @spec valid_id?(String.t()) :: boolean()
  def valid_id?(id) do
    String.match?(id, ~r/^[a-z0-9_]+--[a-z0-9_]+$/)
  end

  defp build_navigation_fixture("screen_transition--settings_profile") do
    Interaction.navigation_transition(
      intent: :open_settings_screen,
      element_id: "settings-link",
      scope: :screen,
      action: :navigate_to,
      screen: :settings,
      params: %{tab: :profile},
      mapping: %{origin: :workspace}
    )
  end

  defp build_navigation_fixture("replace_transition--home") do
    Interaction.navigation_transition(
      intent: :replace_home_screen,
      element_id: "home-link",
      scope: :screen,
      action: :replace_with,
      screen: :home,
      params: %{source: :command_palette},
      mapping: %{source: :command_palette}
    )
  end

  defp build_navigation_fixture("history_transition--back") do
    Interaction.navigation_transition(
      intent: :go_back_history,
      element_id: "back-button",
      scope: :screen,
      action: :go_back,
      metadata: %{source: :header},
      mapping: %{source: :header}
    )
  end

  defp build_navigation_fixture("modal_transition--settings_dialog") do
    Interaction.navigation_transition(
      intent: :open_settings_modal,
      element_id: "settings-dialog-button",
      scope: :screen,
      action: :open_modal,
      modal: :settings_dialog,
      params: %{mode: :advanced},
      metadata: %{surface: :workspace},
      mapping: %{surface: :workspace}
    )
  end

  defp build_fixture("foundational--workspace_chrome") do
    semantic_hero =
      Foundational.hero(
        [
          {:supporting, Foundational.badge("Semantic", id: "semantic-badge", icon: :sparkles)},
          {:supporting, Foundational.text("Canonical workspace shell", id: "semantic-hero-copy")},
          {:actions,
           Foundational.button("Review", id: "semantic-hero-action", action: [intent: :review])}
        ],
        id: "semantic-hero",
        eyebrow: "Unified IUR",
        title: "Workspace chrome",
        message: "Foundational semantics stay distinct from generic containers.",
        theme: :workspace,
        style_refs: [:surface_card]
      )

    hero =
      Container.box(
        [
          {:content, Foundational.icon(:sparkles, id: "hero-icon", fallback_text: "*")},
          {:content,
           Foundational.text("Unified Workspace", id: "hero-title", style_refs: [:hero_title])},
          {:content,
           Foundational.image("asset://workspace.png",
             id: "hero-image",
             alt_text: "Workspace preview"
           )},
          {:content, Foundational.label("Canonical UI shell", id: "hero-label")}
        ],
        id: "hero-box",
        theme: :workspace,
        style_refs: [:surface_card]
      )

    toolbar =
      Layout.row(
        [
          {:content,
           Foundational.button("Save",
             id: "save-button",
             action: [intent: :save_workspace],
             style_refs: [:primary_button]
           )},
          {:content, Foundational.spacer(id: "toolbar-spacer", grow: 1)},
          {:content, Foundational.link("Docs", "https://specled.dev/home", id: "docs-link")},
          {:content, Foundational.separator(id: "toolbar-divider")},
          {:content,
           Foundational.content(
             [{:content, Foundational.text("Workspace tools", id: "toolbar-copy")}],
             id: "toolbar-content"
           )}
        ],
        id: "toolbar-row",
        gap: 1
      )

    nav =
      Layout.column(
        [
          {:content,
           Navigation.menu(
             [
               [id: :home, label: "Home", active?: true],
               [id: :settings, label: "Settings"]
             ],
             id: "workspace-menu"
           )},
          {:content,
           Navigation.tabs(
             [
               [id: :overview, label: "Overview", active?: true],
               [id: :activity, label: "Activity"]
             ],
             id: "workspace-tabs"
           )}
        ],
        id: "navigation-column"
      )

    Layout.column(
      [
        {:header, semantic_hero},
        {:header, hero},
        {:header, toolbar},
        {:content, nav}
      ],
      id: "workspace-chrome",
      theme: :workspace
    )
  end

  defp build_fixture("forms--profile_editor") do
    fields = [
      Forms.form_field(Input.text_input(id: "name-input", name: :name, value: "Pascal"),
        id: "name-field",
        label: "Name"
      ),
      Forms.field(Input.numeric_input(id: "age-input", name: :age, value: 42),
        id: "age-field",
        label: "Age"
      ),
      Forms.field(Input.toggle(id: "alerts-toggle", name: :alerts, value: true),
        id: "alerts-field",
        label: "Alerts"
      ),
      Forms.field(
        Input.checkbox(
          id: "terms-checkbox",
          name: :terms,
          value: true,
          label_text: "Accept terms"
        ),
        id: "terms-field",
        label: "Terms"
      ),
      Forms.field(
        Input.radio_group(
          [
            [id: :free, value: :free, label: "Free"],
            [id: :pro, value: :pro, label: "Pro", selected?: true]
          ],
          id: "plan-radio",
          name: :plan
        ),
        id: "plan-field",
        label: "Plan"
      ),
      Forms.field(
        Input.select([[value: "en", label: "English"], [value: "fr", label: "French"]],
          id: "locale-select",
          name: :locale,
          value: "en"
        ),
        id: "locale-field",
        label: "Locale"
      ),
      Forms.field(
        Input.pick_list(
          [[value: :specs, label: "Specs", selected?: true], [value: :tests, label: "Tests"]],
          id: "artifact-picklist",
          name: :artifacts
        ),
        id: "artifacts-field",
        label: "Artifacts"
      ),
      Forms.field(Input.slider(id: "volume-slider", name: :volume, value: 6),
        id: "volume-field",
        label: "Volume"
      ),
      Forms.field(Input.date_input(id: "start-date", name: :start_date),
        id: "date-field",
        label: "Start date"
      ),
      Forms.field(Input.time_input(id: "start-time", name: :start_time),
        id: "time-field",
        label: "Start time"
      ),
      Forms.field(Input.file_input(id: "avatar-file", name: :avatar, accept: [".png", ".jpg"]),
        id: "file-field",
        label: "Avatar"
      )
    ]

    grouped_fields =
      fields
      |> Enum.map(&{:fields, &1})

    host_shell =
      Forms.host_form_shell(
        [
          {:fields,
           Forms.form_field(Input.text_input(id: "host-display-name-input", name: :display_name),
             id: "host-display-name-field",
             label: "Display name"
           )},
          {:actions,
           Foundational.button("Host Save",
             id: "host-profile-save",
             action: [intent: :host_save_profile]
           )}
        ],
        id: "profile-host-shell",
        submit_intent: :host_save_profile,
        validation_summary: "Host validates profile shell changes",
        action_placement: :footer
      )

    Forms.form_builder(
      [
        {:content,
         Forms.field_group(
           grouped_fields,
           id: "profile-group",
           legend: "Profile",
           group_description: "Profile editor fixture"
         )},
        {:content, host_shell},
        {:actions,
         Layout.row(
           [
             {:content,
              Foundational.button("Save",
                id: "profile-save",
                action: [intent: :save_profile],
                style_refs: [:primary_button]
              )},
             {:content,
              Foundational.button("Cancel",
                id: "profile-cancel",
                action: [intent: :cancel_profile]
              )}
           ],
           id: "profile-actions"
         )}
      ],
      id: "profile-editor",
      name: :profile,
      path: [:profile],
      submit_intent: :save_profile,
      theme: :workspace,
      style_refs: [:form_surface]
    )
  end

  defp build_fixture("data--content_and_feedback") do
    Layout.grid(
      [
        {:content,
         Data.list(
           [
             [id: :overview, label: "Overview", selected?: true],
             [id: :details, label: "Details"]
           ],
           id: "content-list"
         )},
        {:content,
         Data.table(
           [
             [id: :name, label: "Name"],
             [id: :status, label: "Status"]
           ],
           [
             [id: "row-1", cells: ["Spec", "Ready"], selected?: true],
             [id: "row-2", cells: ["Tests", "Running"]]
           ],
           id: "content-table"
         )},
        {:content,
         Data.tree_view(
           [
             [id: :root, label: "Root", expanded?: true, children: [[id: :child, label: "Child"]]]
           ],
           id: "content-tree"
         )},
        {:content,
         Data.stat(
           id: "release-stat",
           title: "Release coverage",
           value: "82%",
           message: "Semantic surface parity"
         )},
        {:content,
         Data.key_value("Owner", "Platform UI",
           id: "owner-pair",
           description: "Maintaining the canonical semantic rollout"
         )},
        {:content,
         Data.info_list(
           [
             [
               id: :badge,
               title: "Badge",
               value: "Ready",
               description: "Foundational semantic display"
             ],
             [
               id: :form_field,
               title: "Form field",
               value: "Ready",
               description: "Semantic form composition",
               status: :active
             ]
           ],
           id: "semantic-info-list",
           ordered?: true,
           empty_state: "No semantic notes"
         )},
        {:content,
         Collection.repeated_collection(
           Layout.row(
             [
               {:content,
                Foundational.text("Artifact title",
                  id: "artifact-title-template",
                  bindings: [Binding.row_value(:artifact, :title)]
                )},
               {:content,
                Foundational.badge("Artifact status",
                  id: "artifact-status-template",
                  bindings: [Binding.row_style_variant(:artifact, :status)]
                )}
             ],
             id: "artifact-row-template"
           ),
           id: "artifact-rows",
           source: [
             name: :artifacts,
             path: [:artifacts],
             value: [
               %{id: "artifact-1", title: "artifact.tar", status: :ready},
               %{id: "artifact-2", title: "docs.zip", status: :queued}
             ]
           ],
           item_alias: :artifact,
           index_alias: :artifact_index,
           key_path: [:id],
           row_scope_bindings: [
             Binding.row_key(:artifact, :id),
             Binding.row_index(:artifact_index)
           ],
           empty_state: "No artifacts"
         )},
        {:content,
         Feedback.status("Healthy", id: "status-widget", severity: :success, status: :ready)},
        {:content,
         Feedback.progress(
           id: "sync-progress",
           current: 5,
           total: 8,
           label: "Sync",
           status: :running
         )},
        {:content, Feedback.gauge(id: "cpu-gauge", value: 72, label: "CPU", severity: :warning)},
        {:content,
         Feedback.inline_feedback("Deployment completed.",
           id: "feedback-inline",
           title: "Success",
           severity: :success
         )}
      ],
      id: "content-grid",
      columns: 2,
      gap: 2
    )
  end

  defp build_fixture("portable_widgets--ash_ui_portability") do
    repeated =
      Collection.repeated_collection(
        Layout.row(
          [
            {:content,
             Semantic.artifact_row(Binding.row_value(:artifact, :record), "Artifact",
               id: "portable-artifact-template",
               status: :ready
             )},
            {:content,
             Semantic.list_item_multi_column(Binding.row_value(:artifact, :columns),
               id: "portable-artifact-summary-template",
               label: "Artifact summary",
               value: Binding.row_index(:row),
               status: :ready
             )}
          ],
          id: "portable-artifact-row-template"
        ),
        id: "portable-artifact-rows",
        source: [
          name: :artifacts,
          path: [:artifacts],
          value: [
            %{id: "artifact-1", record: %{id: "artifact-1"}, columns: %{name: "artifact.tar"}}
          ]
        ],
        item_alias: :artifact,
        index_alias: :row,
        key_path: [:id],
        empty_state: "No artifacts"
      )

    Layout.grid(
      [
        {:content,
         Semantic.disclosure("Release notes",
           id: "portable-disclosure",
           open?: true,
           content_label: "Expanded release notes"
         )},
        {:content, Semantic.kicker("Workflow", id: "portable-kicker", icon: :sparkles)},
        {:content,
         Semantic.avatar("Pat Charbon",
           id: "portable-avatar",
           initials: "PC",
           status: :online
         )},
        {:content,
         Semantic.presence_dot(:online,
           id: "portable-presence",
           label: "Assignee online",
           pulse?: true
         )},
        {:content,
         Semantic.segmented_button_group([compact: "Compact", detailed: "Detailed"],
           id: "portable-segments",
           active_item: :compact
         )},
        {:content,
         Semantic.list_item_multi_column([name: "artifact.tar", status: "ready"],
           id: "portable-list-item",
           label: "Artifact",
           status: :ready
         )},
        {:content,
         Semantic.artifact_row(%{id: "artifact-1"}, "artifact.tar",
           id: "portable-artifact-row",
           status: :ready,
           timestamp: "2026-05-13T10:30:00Z"
         )},
        {:content,
         Semantic.sticky_header("Results",
           id: "portable-sticky-header",
           stuck?: true,
           elevation: :raised
         )},
        {:content,
         Workflow.pipeline_stepper_horizontal([:queued, :building, :deployed],
           id: "portable-pipeline",
           active_item: :building,
           status: :running
         )},
        {:content,
         Workflow.segmented_progress_bar([queued: 20, building: 55, deployed: 25],
           id: "portable-progress",
           current: 55,
           maximum: 100
         )},
        {:content,
         Workflow.workflow_stage_list_vertical([:plan, :build, :deploy],
           id: "portable-stages",
           active_item: :build
         )},
        {:content,
         Workflow.meter_thin(82,
           id: "portable-meter",
           maximum: 100,
           severity: :success
         )},
        {:content,
         Workflow.slide_over_panel(
           [{:content, Foundational.text("Details", id: "portable-panel-copy")}],
           id: "portable-panel",
           title: "Details",
           placement: :end,
           visible?: true
         )},
        {:content,
         Workflow.event_callout("Build completed",
           id: "portable-callout",
           severity: :success,
           timestamp: "2026-05-13T10:35:00Z"
         )},
        {:content,
         Workflow.redline_inline("Draft", "Ready",
           id: "portable-redline",
           label: "Status change"
         )},
        {:content,
         Workflow.code_block_syntax_highlighted("IO.puts(\"ready\")",
           id: "portable-code",
           language: :elixir,
           wrap?: true
         )},
        {:content,
         Workflow.chat_composer(
           id: "portable-composer",
           placeholder: "Add a review note",
           submit_intent: :send_review,
           actions: [send: "Send"]
         )},
        {:content, repeated}
      ],
      id: "portable-widget-grid",
      columns: 3,
      gap: 2
    )
  end

  defp build_fixture("display--layered_workspace") do
    detail =
      Container.box(
        [
          {:content, Foundational.text("Detail panel", id: "detail-title")},
          {:content, Foundational.text("Scrollable content", id: "detail-copy")}
        ],
        id: "detail-box",
        padding: 1,
        theme: :workspace,
        style_refs: [:surface_card]
      )

    viewport = Layout.scroll_region(detail, id: "detail-viewport", offset: 12, height: 20)

    scroll_bar =
      Layout.scroll_bar(
        id: "detail-scrollbar",
        position: 12,
        viewport_size: 20,
        content_size: 120
      )

    workspace =
      Layout.split_pane(
        Navigation.menu(
          [[id: :overview, label: "Overview", active?: true], [id: :metrics, label: "Metrics"]],
          id: "display-menu"
        ),
        Layout.row([{:content, viewport}, {:scrollbar, scroll_bar}], id: "detail-row"),
        id: "workspace-split",
        ratio: 0.25
      )

    overlay_base =
      Layout.stack(
        [
          {:base, workspace},
          {:overlay, Layer.toast(Foundational.text("Saved", id: "toast-copy"), id: "save-toast")},
          {:overlay,
           Layer.context_menu([[id: :rename, label: "Rename"], [id: :delete, label: "Delete"]],
             id: "context-menu"
           )}
        ],
        id: "display-stack"
      )

    Layer.overlay(
      overlay_base,
      [
        {:dialog,
         Layer.dialog(Foundational.text("Preferences", id: "dialog-copy"),
           id: "preferences-dialog",
           title: "Preferences"
         )},
        {:alert,
         Layer.alert_dialog(Foundational.text("Delete this item?", id: "alert-copy"),
           id: "delete-alert",
           title: "Confirm"
         )}
      ],
      id: "layered-workspace",
      theme: :workspace,
      style_refs: [:workspace_overlay]
    )
  end

  defp build_fixture("advanced--operations_center") do
    Layout.grid(
      [
        {:content,
         Advanced.stream_widget(
           [
             [id: "stream-1", message: "Build started", severity: :info],
             [id: "stream-2", message: "Build finished", severity: :success]
           ],
           id: "stream-widget"
         )},
        {:content,
         Advanced.log_viewer(
           [
             [
               id: "log-1",
               message: "Accepted connection",
               severity: :info,
               timestamp: "2026-03-14T10:00:00Z"
             ]
           ],
           id: "log-viewer"
         )},
        {:content,
         Advanced.process_monitor(
           [
             [id: "proc-1", name: "Renderer", memory: 128],
             [id: "proc-2", name: "Worker", memory: 64]
           ],
           id: "process-monitor"
         )},
        {:content,
         Advanced.cluster_dashboard(
           [
             [id: "node-a", status: :healthy],
             [id: "node-b", status: :degraded]
           ],
           id: "cluster-dashboard"
         )},
        {:content,
         Advanced.command_palette(
           [
             [id: :open_file, label: "Open File", value: :open_file],
             [id: :reload, label: "Reload", value: :reload]
           ],
           id: "command-palette",
           interactions: [UnifiedIUR.Interaction.command(intent: :open_file, command: :open_file)]
         )},
        {:content, Advanced.markdown_viewer("# Operations", id: "markdown-viewer")},
        {:content,
         Advanced.supervision_tree_viewer(
           [
             [id: :root, label: "App", children: [[id: :child, label: "Worker"]]]
           ],
           id: "supervision-tree"
         )},
        {:content, Canvas.sparkline([2, 4, 3, 5, 7], id: "sparkline")},
        {:content,
         Canvas.bar_chart(
           [
             [id: :requests, label: "Requests", values: [12, 18, 16]]
           ],
           id: "bar-chart"
         )},
        {:content,
         Canvas.line_chart(
           [
             [id: :latency, label: "Latency", values: [90, 80, 85]]
           ],
           id: "line-chart"
         )},
        {:content,
         Canvas.surface(
           [
             [kind: :cell, position: {0, 0}, text: "A", style_refs: [:accent]],
             [kind: :cell, position: {1, 0}, text: "B"]
           ],
           id: "canvas-surface",
           width: 20,
           height: 10
         )}
      ],
      id: "operations-center",
      columns: 2,
      gap: 2,
      theme: :workspace
    )
  end

  defp attachment_family_report(fixtures, predicate) do
    covered_fixture_ids =
      fixtures
      |> Enum.filter(fn fixture ->
        fixture.element
        |> Interoperability.walk()
        |> Enum.any?(predicate)
      end)
      |> Enum.map(& &1.id)

    %{
      covered_fixture_ids: covered_fixture_ids,
      covered?: covered_fixture_ids != []
    }
  end

  defp theme_token_refs?(%{token_refs: refs}) when is_list(refs), do: refs != []
  defp theme_token_refs?(_theme), do: false
end
