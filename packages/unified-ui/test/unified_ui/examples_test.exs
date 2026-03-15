defmodule UnifiedUi.ExamplesTest do
  use ExUnit.Case, async: true

  test "registers maintained example modules through package reference helpers" do
    assert UnifiedUi.Examples.modules() == [
             UnifiedUi.Examples.FoundationalScreen,
             UnifiedUi.Examples.ProfileForm
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
             }
           ]
  end
end
