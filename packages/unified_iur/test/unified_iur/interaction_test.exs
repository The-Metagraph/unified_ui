defmodule UnifiedIUR.InteractionTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Binding
  alias UnifiedIUR.Interaction
  alias UnifiedIUR.Interactions

  test "exposes canonical interaction and binding modules" do
    assert %{interaction: Interaction, binding: Binding} = Interactions.modules()

    assert [:click, :change, :submit, :open, :close, :selection, :focus, :navigation, :command] ==
             Interaction.families()
  end

  test "builds standard interaction descriptor families with canonical source, target, and payload metadata" do
    click =
      Interaction.click(
        intent: :open_settings,
        element_id: "settings-button",
        path: [:settings],
        mapping: %{label: :label}
      )

    submit =
      Interaction.submit(
        intent: :save_profile,
        element_id: "profile-form",
        binding: [:profile],
        propagation: :bubble
      )

    command =
      Interaction.command(
        intent: :open_file,
        element_id: "command-palette",
        command: :open_file,
        transient?: true
      )

    assert %Interaction{
             family: :click,
             intent: :open_settings,
             source: %{element_id: "settings-button"},
             target: %{path: [:settings]},
             payload: %{mapping: %{label: :label}}
           } = click

    assert %Interaction{
             family: :submit,
             target: %{binding: [:profile]},
             metadata: %{propagation: :bubble}
           } = submit

    assert %Interaction{
             family: :command,
             payload: %{command: :open_file},
             metadata: %{transient?: true}
           } = command
  end

  test "builds bindings with source paths, dependencies, and derived-value metadata" do
    binding =
      Binding.new(
        name: :email,
        path: [:profile, :email],
        value: "user@example.com",
        format: :string,
        source: :form
      )
      |> Binding.put_dependency([:profile, :account_id], source: :session)
      |> Binding.put_derived(:normalized, %{trim?: true, lowercase?: true})

    assert %Binding{
             name: :email,
             path: [:profile, :email],
             value: "user@example.com",
             format: :string,
             source: :form,
             depends_on: [%{path: [:profile, :account_id], source: :session}],
             derived: %{normalized: %{trim?: true, lowercase?: true}}
           } = binding
  end
end
