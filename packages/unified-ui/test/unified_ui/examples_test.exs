defmodule UnifiedUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "registers maintained example modules through package reference helpers" do
    assert UnifiedUi.Examples.modules() == [
             UnifiedUi.Examples.FoundationalScreen,
             UnifiedUi.Examples.ProfileForm,
             UnifiedUi.Examples.OverlayWorkspace
           ]

    assert UnifiedUi.Reference.example_catalog() == [
             %{
               id: :foundational_screen,
               category: :foundational,
               module: UnifiedUi.Examples.FoundationalScreen,
               constructs: [:foundational_visual, :layout],
               summary: "Minimal screen showing foundational widgets and baseline layouts."
             },
             %{
               id: :profile_form,
               category: :form_workflow,
               module: UnifiedUi.Examples.ProfileForm,
               constructs: [:input, :navigation, :forms],
               summary: "Baseline form workflow with grouped fields, tabs, and command actions."
             },
             %{
               id: :overlay_workspace,
               category: :advanced_flow,
               module: UnifiedUi.Examples.OverlayWorkspace,
               constructs: [:overlay, :display, :layout],
               summary: "Advanced overlay and split-pane workflow with contextual actions."
             }
           ]
  end

  test "exposes example composition summaries without runtime-library dependencies" do
    assert UnifiedUi.Info.example_summaries() == [
             %{
               id: :foundational_screen,
               category: :foundational,
               module: UnifiedUi.Examples.FoundationalScreen,
               constructs: [:foundational_visual, :layout],
               summary: "Minimal screen showing foundational widgets and baseline layouts.",
               composition: [
                 %{
                   id: :shell,
                   family: :layout,
                   kind: :box,
                   summary: "Foundational shell",
                   children: [
                     %{
                       id: :headline,
                       family: :foundational,
                       kind: :text,
                       role: :text,
                       value: "Welcome to UnifiedUi"
                     },
                     %{
                       id: :primary_action,
                       family: :foundational,
                       kind: :button,
                       label: "Get started"
                     }
                   ]
                 },
                 %{
                   id: :shortcut_bar,
                   family: :layout,
                   kind: :row,
                   children: [
                     %{id: :main_menu, family: :navigation, kind: :menu},
                     %{
                       id: :docs_link,
                       family: :foundational,
                       kind: :link,
                       label: "Open docs",
                       target: "https://specled.dev/home"
                     }
                   ]
                 }
               ]
             },
             %{
               id: :profile_form,
               category: :form_workflow,
               module: UnifiedUi.Examples.ProfileForm,
               constructs: [:input, :navigation, :forms],
               summary: "Baseline form workflow with grouped fields, tabs, and command actions.",
               composition: [
                 %{
                   id: :profile_form,
                   family: :forms,
                   kind: :form_builder,
                   summary: "Profile update workflow",
                   children: [
                     %{
                       id: :profile_identity,
                       family: :forms,
                       kind: :field_group,
                       children: [
                         %{
                           id: :display_name,
                           family: :forms,
                           kind: :field,
                           label: "Display name",
                           children: [
                             %{id: :display_name_input, family: :input, kind: :text_input}
                           ]
                         },
                         %{
                           id: :role,
                           family: :forms,
                           kind: :field,
                           label: "Role",
                           children: [%{id: :role_select, family: :input, kind: :select}]
                         }
                       ]
                     },
                     %{id: :profile_tabs, family: :navigation, kind: :tabs},
                     %{
                       id: :profile_commands,
                       family: :navigation,
                       kind: :command_palette,
                       label: "Profile actions"
                     }
                   ]
                 }
               ]
             },
             %{
               id: :overlay_workspace,
               category: :advanced_flow,
               module: UnifiedUi.Examples.OverlayWorkspace,
               constructs: [:overlay, :display, :layout],
               summary: "Advanced overlay and split-pane workflow with contextual actions.",
               composition: [
                 %{
                   id: :workspace_shell,
                   family: :layout,
                   kind: :row,
                   children: [
                     %{
                       id: :open_settings,
                       family: :foundational,
                       kind: :button,
                       label: "Open settings"
                     },
                     %{
                       id: :open_context,
                       family: :foundational,
                       kind: :button,
                       label: "Open menu"
                     }
                   ]
                 },
                 %{
                   id: :settings_panel,
                   family: :layout,
                   kind: :box,
                   summary: "Settings panel",
                   children: [
                     %{
                       id: :settings_heading,
                       family: :foundational,
                       kind: :text,
                       role: :text,
                       value: "Workspace settings"
                     },
                     %{
                       id: :settings_copy,
                       family: :foundational,
                       kind: :text,
                       role: :text,
                       value: "Advanced workspace options"
                     }
                   ]
                 },
                 %{
                   id: :settings_dialog,
                   family: :overlay,
                   kind: :dialog,
                   title: "Settings",
                   content_ref: :settings_panel,
                   trigger_ref: :open_settings
                 },
                 %{
                   id: :workspace_menu,
                   family: :overlay,
                   kind: :context_menu,
                   target_ref: :workspace_shell,
                   trigger_ref: :open_context,
                   placement: :bottom_start
                 },
                 %{
                   id: :save_toast,
                   family: :overlay,
                   kind: :toast,
                   title: "Saved",
                   message: "Workspace settings updated",
                   severity: :success,
                   placement: :bottom_end
                 },
                 %{
                   id: :workspace_split,
                   family: :display,
                   kind: :split_pane,
                   primary_ref: :workspace_shell,
                   secondary_ref: :settings_panel,
                   ratio: 0.35
                 },
                 %{
                   id: :workspace_scroll,
                   family: :display,
                   kind: :scroll_bar,
                   target_ref: :workspace_shell,
                   position: 4,
                   viewport_size: 24,
                   content_size: 120
                 }
               ]
             }
           ]
  end
end
