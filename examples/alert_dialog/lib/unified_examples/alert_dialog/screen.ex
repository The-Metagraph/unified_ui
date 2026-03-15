defmodule UnifiedExamples.AlertDialog.Screen do
  @moduledoc """
  Shared-template alert-dialog proof for the standalone example-app suite.
  """

  alias UnifiedExamples.Shared.Fixtures

  @alert_dialog_snapshot Fixtures.alert_dialog_snapshot()

  use UnifiedExamples.Shared.Template,
    id: :alert_dialog_example_screen,
    title: "Alert Dialog Widget Example",
    summary: "Focused overlay example using the shared suite shell",
    widget: :alert_dialog,
    notes:
      "Alert-dialog examples foreground one canonical destructive confirmation surface inside the shared shell."

  example_panel do
    button :alert_dialog_example_trigger do
      label(@alert_dialog_snapshot.trigger_label)
      theme_ref(:example_suite_default)
      tone(:accent)
      variant(:quiet)
    end

    alert_dialog :alert_dialog_example_primary_alert_dialog do
      title(@alert_dialog_snapshot.title)
      message(@alert_dialog_snapshot.message)
      trigger_ref(:alert_dialog_example_trigger)
      visible?(true)
      confirm_intent(:confirm_escalation)
      dismiss_intent(:cancel_escalation)
      severity(@alert_dialog_snapshot.severity)
      theme_ref(:example_suite_default)
      tone(:surface)
      variant(:quiet)
    end
  end
end
