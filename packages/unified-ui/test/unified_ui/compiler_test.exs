defmodule UnifiedUi.CompilerTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Reference
  alias UnifiedUi.Compiler

  defmodule CompiledScreen do
    use UnifiedUi.Dsl

    identity do
      id(:compiled_screen)
      title("Compiled Screen")
      authored_ref([:tests, :compiled_screen])
      tags([:compiler, :phase_5])
    end

    composition do
      root(:compiled_screen_root)
      mode(:screen)
      summary("Compiler baseline screen")

      box :shell do
        text :headline do
          value("Compiler baseline")
        end

        button :primary_action do
          label("Continue")
          action_intent(:continue)
        end
      end

      row :shortcut_bar do
        menu :main_menu do
          items(home: "Home", docs: "Docs")
          active_item(:home)
        end

        link :docs_link do
          label("Open docs")
          target("https://specled.dev/home")
        end
      end
    end
  end

  defmodule SignalWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:signal_workspace)
      title("Signal Workspace")
      authored_ref([:tests, :signal_workspace])
    end

    composition do
      root(:signal_workspace_root)
      mode(:screen)

      form_builder :profile_form do
        binding_refs([:profile_form_data])
        interaction_refs([:profile_change, :profile_submit])
      end

      button :save_button do
        label("Save")
        interaction_refs([:profile_submit])
      end
    end

    signals do
      namespace(:workspace)
      default_target(:session)

      data_binding do
        id(:profile_form_data)
        path([:profile])
        scope([:screen])
        default(%{display_name: "", role: :member})
      end

      interaction do
        id(:profile_change)
        family(:change)
        intent(:update_profile)
        source_context(element_id: :profile_form, scope: :screen)
        target_intent(binding: :profile_form_data, entity: :profile)
        payload_mapping(profile: binding_ref(:profile_form_data), phase: :draft)
      end

      interaction do
        id(:profile_submit)
        family(:submit)
        intent(:save_profile)
        source_context(element_id: :save_button, scope: :screen)
        target_intent(binding: :profile_form_data, entity: :profile)
        payload_mapping(profile: binding_ref(:profile_form_data), action: :save)
        binding_refs([:profile_form_data])
      end
    end
  end

  test "compiles authored modules into canonical result structs and root IUR output" do
    {:ok, result} = Compiler.compile(CompiledScreen)

    assert result.module == CompiledScreen
    assert result.identity.id == :compiled_screen
    assert result.composition.root == :compiled_screen_root
    assert result.iur.id == :compiled_screen_root
    assert result.iur.type == :composite
    assert result.iur.kind == :screen

    assert Enum.map(result.iur.children, fn child ->
             {child.slot, child.element.id, child.element.kind}
           end) == [
             {:default, :shell, :box},
             {:default, :shortcut_bar, :row}
           ]

    assert Compiler.iur!(CompiledScreen).id == :compiled_screen_root

    assert Compiler.summary(CompiledScreen) == %{
             module: CompiledScreen,
             identity_id: :compiled_screen,
             authored_ref: [:tests, :compiled_screen],
             root_id: :compiled_screen_root,
             mode: :screen,
             default_theme: nil,
             top_level_children: [
               %{slot: :default, id: :shell, type: :layout, kind: :box},
               %{slot: :default, id: :shortcut_bar, type: :layout, kind: :row}
             ],
             theme_ids: [],
             binding_names: [],
             interaction_families: [],
             interaction_intents: [],
             trace: %{
               authored_ids: [
                 :docs_link,
                 :headline,
                 :main_menu,
                 :primary_action,
                 :shell,
                 :shortcut_bar
               ],
               binding_ids: [],
               interaction_ids: [],
               theme_ids: []
             }
           }

    assert Reference.summarize_tree(result.iur) == %{
             total_elements: 7,
             element_ids: [
               :compiled_screen_root,
               :shell,
               :headline,
               :primary_action,
               :shortcut_bar,
               :main_menu,
               :docs_link
             ],
             type_histogram: %{composite: 1, layout: 2, widget: 4},
             shape_signature: %{
               type: :composite,
               kind: :screen,
               child_shape: :multi,
               slots: [
                 %{
                   slot: :default,
                   present?: true,
                   child: %{
                     type: :layout,
                     kind: :box,
                     child_shape: :multi,
                     slots: [
                       %{
                         slot: :default,
                         present?: true,
                         child: %{type: :widget, kind: :text, child_shape: :leaf, slots: []}
                       },
                       %{
                         slot: :default,
                         present?: true,
                         child: %{type: :widget, kind: :button, child_shape: :leaf, slots: []}
                       }
                     ]
                   }
                 },
                 %{
                   slot: :default,
                   present?: true,
                   child: %{
                     type: :layout,
                     kind: :row,
                     child_shape: :multi,
                     slots: [
                       %{
                         slot: :default,
                         present?: true,
                         child: %{type: :widget, kind: :menu, child_shape: :leaf, slots: []}
                       },
                       %{
                         slot: :default,
                         present?: true,
                         child: %{type: :widget, kind: :link, child_shape: :leaf, slots: []}
                       }
                     ]
                   }
                 }
               ]
             }
           }
  end

  test "compiles authored bindings and interactions into canonical descriptors" do
    {:ok, result} = Compiler.compile(SignalWorkspace)

    assert result.bindings == [
             %UnifiedIUR.Binding{
               name: :profile_form_data,
               path: [:profile],
               scope: [:screen],
               default: %{display_name: "", role: :member},
               metadata: %{authored_id: :profile_form_data, summary: nil}
             }
           ]

    assert Enum.map(result.interactions, &{&1.family, &1.intent}) == [
             {:change, :update_profile},
             {:submit, :save_profile}
           ]

    assert Enum.map(result.iur.attributes.bindings, &{&1.name, &1.path}) == [
             {:profile_form_data, [:profile]}
           ]

    assert Enum.map(result.iur.attributes.interactions, &{&1.family, &1.intent}) == [
             {:change, :update_profile},
             {:submit, :save_profile}
           ]

    assert result.trace.binding_by_id[:profile_form_data].path == [:profile]

    assert result.trace.interaction_by_id[:profile_submit] == %UnifiedIUR.Interaction{
             family: :submit,
             intent: :save_profile,
             source: %{element_id: :save_button, scope: :screen},
             target: %{
               binding: %{
                 id: :profile_form_data,
                 kind: :binding_ref,
                 name: :profile_form_data,
                 path: [:profile],
                 scope: [:screen]
               },
               entity: :profile
             },
             payload: %{
               action: :save,
               profile: %{
                 id: :profile_form_data,
                 kind: :binding_ref,
                 name: :profile_form_data,
                 path: [:profile],
                 scope: [:screen]
               }
             },
             metadata: %{
               summary: nil,
               authored_id: :profile_submit,
               binding_refs: [
                 %{
                   id: :profile_form_data,
                   kind: :binding_ref,
                   name: :profile_form_data,
                   path: [:profile],
                   scope: [:screen]
                 }
               ]
             }
           }
  end
end
