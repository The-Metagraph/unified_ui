defmodule UnifiedUi.SignalsTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Info
  alias UnifiedUi.Signals

  defmodule SignalWorkspace do
    use UnifiedUi.Dsl

    identity do
      id(:signal_workspace)
      title("Signal Workspace")
      authored_ref([:examples, :signal_workspace])
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
        interaction_refs([:profile_submit, :open_commands])
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
        derived(%{source: :form_builder})
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

      interaction do
        id(:open_commands)
        family(:command)
        intent(:open_command_palette)
        source_context(element_id: :save_button)
        target_intent(command: :workspace_palette)
        payload_mapping(source: :keyboard_shortcut)
      end
    end
  end

  test "authors canonical bindings and interactions through the signals section" do
    assert Enum.map(Signals.bindings(SignalWorkspace), & &1.id) == [:profile_form_data]

    assert Enum.map(Signals.interactions(SignalWorkspace), & &1.id) == [
             :profile_change,
             :profile_submit,
             :open_commands
           ]
  end

  test "summarizes module signal configuration and supported families" do
    assert Signals.families() == [
             :click,
             :change,
             :submit,
             :open,
             :close,
             :focus,
             :selection,
             :navigation,
             :command
           ]

    assert Signals.module_summary(SignalWorkspace) == %{
             namespace: :workspace,
             default_target: :session,
             mode: :canonical,
             families: [
               :click,
               :change,
               :submit,
               :open,
               :close,
               :focus,
               :selection,
               :navigation,
               :command
             ],
             bindings: [
               %{
                 id: :profile_form_data,
                 path: [:profile],
                 scope: [:screen],
                 default: %{display_name: "", role: :member},
                 collection?: false,
                 derived: %{source: :form_builder}
               }
             ],
             interactions: [
               %{
                 id: :profile_change,
                 family: :change,
                 intent: :update_profile,
                 source_context: %{element_id: :profile_form, scope: :screen},
                 target_intent: %{binding: :profile_form_data, entity: :profile},
                 payload_mapping: %{
                   profile: %{kind: :binding_ref, id: :profile_form_data},
                   phase: :draft
                 }
               },
               %{
                 id: :profile_submit,
                 family: :submit,
                 intent: :save_profile,
                 source_context: %{element_id: :save_button, scope: :screen},
                 target_intent: %{binding: :profile_form_data, entity: :profile},
                 payload_mapping: %{
                   profile: %{kind: :binding_ref, id: :profile_form_data},
                   action: :save
                 },
                 binding_refs: [%{kind: :binding_ref, id: :profile_form_data}]
               },
               %{
                 id: :open_commands,
                 family: :command,
                 intent: :open_command_palette,
                 source_context: %{element_id: :save_button},
                 target_intent: %{command: :workspace_palette},
                 payload_mapping: %{source: :keyboard_shortcut}
               }
             ]
           }
  end

  test "attaches authored signal and binding references to composition nodes" do
    [profile_form, save_button] = Info.composition_nodes(SignalWorkspace)

    assert profile_form.binding_refs == [:profile_form_data]
    assert profile_form.interaction_refs == [:profile_change, :profile_submit]

    assert save_button.interaction_refs == [:profile_submit, :open_commands]
  end

  test "exposes canonical signal families through the reference surface" do
    assert UnifiedUi.Reference.signal_families() == Signals.families()
  end
end
