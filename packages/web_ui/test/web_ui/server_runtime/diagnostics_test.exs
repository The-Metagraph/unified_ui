defmodule WebUi.ServerRuntime.DiagnosticsTest do
  use ExUnit.Case

  alias WebUi.ServerRuntime.Diagnostics

  defmodule ValidDiagnosticScreen do
    def id, do: :valid
    def mount_defaults, do: %{}
    def render(_), do: nil
    def event_routes, do: %{}
    def frontend_schema, do: %{version: "1.0", fields: %{}}
    def handle_event(_, _, _), do: {:ok, %{}}
  end

  describe "validate_screen_module/1" do
    test "returns empty list for valid screen" do
      assert Diagnostics.validate_screen_module(ValidDiagnosticScreen) == []
    end

    test "detects missing functions" do
      defmodule IncompleteScreen do
        def id, do: :incomplete
      end

      errors = Diagnostics.validate_screen_module(IncompleteScreen)
      assert length(errors) > 0
      assert Enum.any?(errors, fn
        {:error, %{type: :missing_function}} -> true
        _ -> false
      end)
    end
  end

  describe "validate_envelope/1" do
    test "validates correct envelope" do
      envelope = %{type: "event", payload: %{data: "value"}}
      assert :ok = Diagnostics.validate_envelope(envelope)
    end

    test "returns error for invalid envelope" do
      assert {:error, diagnostic} = Diagnostics.validate_envelope(%{type: "event"})
      assert diagnostic.severity == :error
      assert diagnostic.type == :invalid_envelope
    end
  end

  describe "validate_hooks/1" do
    test "validates all supported hooks" do
      hooks = [:resize_observer, :scroll_tracking, :navigation]
      assert :ok = Diagnostics.validate_hooks(hooks)
    end

    test "returns warning for unsupported hooks" do
      hooks = [:resize_observer, :unknown_hook]
      assert {:error, diagnostic} = Diagnostics.validate_hooks(hooks)
      assert diagnostic.severity == :warning
      assert diagnostic.type == :unsupported_hooks
    end
  end

  describe "validate_runtime_state/1" do
    test "validates correct runtime state" do
      state = %{
        screen: ValidDiagnosticScreen,
        assigns: %{},
        mode: :native,
        event_routes: %{},
        frontend_sync: %{}
      }
      assert Diagnostics.validate_runtime_state(state) == [:ok]
    end

    test "detects missing keys" do
      state = %{screen: ValidDiagnosticScreen}
      assert [{:error, diagnostic}] = Diagnostics.validate_runtime_state(state)
      assert diagnostic.type == :missing_state_keys
      assert :assigns in diagnostic.details.missing
    end
  end
end
