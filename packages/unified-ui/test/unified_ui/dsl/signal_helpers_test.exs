defmodule UnifiedUi.Dsl.SignalHelpersTest do
  @moduledoc """
  Tests for the SignalHelpers module.

  These tests verify that signal helper functions correctly:
  - Normalize signal handlers
  - Extract payload data from signals
  - Build signal structures
  - Match signals against types
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.SignalHelpers

  describe "normalize_handler/1" do
    test "normalizes atom handler" do
      result = SignalHelpers.normalize_handler(:save)
      assert result.type == :atom
      assert result.action == :save
      assert result.payload == %{}
    end

    test "normalizes tuple handler with payload" do
      result = SignalHelpers.normalize_handler({:save, %{form_id: :login}})
      assert result.type == :tuple
      assert result.action == :save
      assert result.payload == %{form_id: :login}
    end

    test "normalizes MFA handler" do
      result = SignalHelpers.normalize_handler({MyModule, :my_func, [:arg1]})
      assert result.type == :mfa
      assert result.module == MyModule
      assert result.function == :my_func
      assert result.args == [:arg1]
    end
  end

  describe "handler_action/1" do
    test "extracts action from atom handler" do
      assert SignalHelpers.handler_action(:save) == :save
    end

    test "extracts action from tuple handler" do
      assert SignalHelpers.handler_action({:save, %{form_id: :login}}) == :save
    end

    test "returns :custom for MFA handler" do
      assert SignalHelpers.handler_action({MyModule, :func, []}) == :custom
    end
  end

  describe "handler_payload/1" do
    test "returns empty map for atom handler" do
      assert SignalHelpers.handler_payload(:save) == %{}
    end

    test "returns payload for tuple handler" do
      payload = SignalHelpers.handler_payload({:save, %{form_id: :login}})
      assert payload == %{form_id: :login}
    end

    test "returns empty map for MFA handler" do
      assert SignalHelpers.handler_payload({MyModule, :func, []}) == %{}
    end
  end

  describe "mfa_handler?/1" do
    test "returns false for atom handler" do
      refute SignalHelpers.mfa_handler?(:save)
    end

    test "returns false for tuple handler" do
      refute SignalHelpers.mfa_handler?({:save, %{form_id: :login}})
    end

    test "returns true for MFA handler" do
      assert SignalHelpers.mfa_handler?({MyModule, :func, []})
    end
  end

  describe "extract_payload/2" do
    setup do
      {:ok, signal} = SignalHelpers.build_signal(:click, %{button_id: :submit_btn, value: "test"})
      {:ok, signal2} = SignalHelpers.build_signal(:change, %{count: 42})
      %{signal: signal, signal2: signal2}
    end

    test "extracts value from signal data", %{signal: signal} do
      assert SignalHelpers.extract_payload(signal, :button_id) == :submit_btn
    end

    test "returns nil for missing key", %{signal: signal} do
      assert SignalHelpers.extract_payload(signal, :missing) == nil
    end

    test "returns nil for nil signal" do
      assert SignalHelpers.extract_payload(nil, :button_id) == nil
    end

    test "extracts string values", %{signal: signal} do
      assert SignalHelpers.extract_payload(signal, :value) == "test"
    end

    test "extracts numeric values", %{signal2: signal2} do
      assert SignalHelpers.extract_payload(signal2, :count) == 42
    end
  end

  describe "extract_payloads/2" do
    setup do
      {:ok, signal} =
        SignalHelpers.build_signal(:click, %{button_id: :submit_btn, value: "test", extra: :data})

      {:ok, signal2} = SignalHelpers.build_signal(:click, %{button_id: :submit_btn})
      %{signal: signal, signal2: signal2}
    end

    test "extracts multiple values from signal data", %{signal: signal} do
      result = SignalHelpers.extract_payloads(signal, [:button_id, :value])
      assert result == %{button_id: :submit_btn, value: "test"}
    end

    test "returns empty map for nil signal" do
      assert SignalHelpers.extract_payloads(nil, [:button_id]) == %{}
    end

    test "returns only keys that exist in signal data", %{signal2: signal2} do
      result = SignalHelpers.extract_payloads(signal2, [:button_id, :missing])
      assert result == %{button_id: :submit_btn}
    end

    test "returns empty map when no keys match", %{signal2: signal2} do
      result = SignalHelpers.extract_payloads(signal2, [:missing1, :missing2])
      assert result == %{}
    end
  end

  describe "signal_type/1" do
    test "returns click signal type" do
      assert SignalHelpers.signal_type(:click) == "unified.button.clicked"
    end

    test "returns change signal type" do
      assert SignalHelpers.signal_type(:change) == "unified.input.changed"
    end

    test "returns submit signal type" do
      assert SignalHelpers.signal_type(:submit) == "unified.form.submitted"
    end
  end

  describe "build_signal/3" do
    test "builds a click signal" do
      {:ok, signal} = SignalHelpers.build_signal(:click, %{button_id: :save_btn})
      assert signal.type == "unified.button.clicked"
      assert signal.data.button_id == :save_btn
      assert signal.source == "/unified_ui"
    end

    test "builds a change signal" do
      {:ok, signal} = SignalHelpers.build_signal(:change, %{input_id: :email, value: "test"})
      assert signal.type == "unified.input.changed"
      assert signal.data.input_id == :email
      assert signal.data.value == "test"
    end

    test "builds a submit signal" do
      {:ok, signal} = SignalHelpers.build_signal(:submit, %{form_id: :login})
      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login
    end

    test "accepts custom source option" do
      {:ok, signal} = SignalHelpers.build_signal(:click, %{}, source: "/my/app")
      assert signal.source == "/my/app"
    end

    test "accepts subject option" do
      {:ok, signal} = SignalHelpers.build_signal(:click, %{}, subject: "my-subject")
      assert signal.subject == "my-subject"
    end
  end

  describe "click_signal/3" do
    test "builds click signal with button_id" do
      {:ok, signal} = SignalHelpers.click_signal(:save_btn)
      assert signal.type == "unified.button.clicked"
      assert signal.data.button_id == :save_btn
    end

    test "includes extra payload" do
      {:ok, signal} = SignalHelpers.click_signal(:save_btn, %{position: {10, 20}})
      assert signal.data.button_id == :save_btn
      assert signal.data.position == {10, 20}
    end

    test "accepts options" do
      {:ok, signal} = SignalHelpers.click_signal(:save_btn, %{}, source: "/test")
      assert signal.source == "/test"
    end
  end

  describe "change_signal/4" do
    test "builds change signal with input_id and value" do
      {:ok, signal} = SignalHelpers.change_signal(:email_input, "test@example.com")
      assert signal.type == "unified.input.changed"
      assert signal.data.input_id == :email_input
      assert signal.data.value == "test@example.com"
    end

    test "includes extra payload" do
      {:ok, signal} =
        SignalHelpers.change_signal(:email_input, "test@example.com", %{validated: true})

      assert signal.data.input_id == :email_input
      assert signal.data.value == "test@example.com"
      assert signal.data.validated == true
    end

    test "accepts numeric values" do
      {:ok, signal} = SignalHelpers.change_signal(:age_input, 25)
      assert signal.data.value == 25
    end
  end

  describe "submit_signal/3" do
    test "builds submit signal with form_id" do
      {:ok, signal} = SignalHelpers.submit_signal(:login_form)
      assert signal.type == "unified.form.submitted"
      assert signal.data.form_id == :login_form
    end

    test "includes form data" do
      form_data = %{email: "test@example.com", password: "secret"}
      {:ok, signal} = SignalHelpers.submit_signal(:login_form, form_data)

      assert signal.data.form_id == :login_form
      assert signal.data.email == "test@example.com"
      assert signal.data.password == "secret"
    end

    test "accepts options" do
      {:ok, signal} = SignalHelpers.submit_signal(:login_form, %{}, source: "/app")
      assert signal.source == "/app"
    end
  end

  describe "match_signal?/2" do
    setup do
      {:ok, click_signal} = SignalHelpers.build_signal(:click, %{})
      {:ok, change_signal} = SignalHelpers.build_signal(:change, %{})
      {:ok, submit_signal} = SignalHelpers.build_signal(:submit, %{})

      %{click: click_signal, change: change_signal, submit: submit_signal}
    end

    test "matches click signal", %{click: click} do
      assert SignalHelpers.match_signal?(click, :click)
    end

    test "matches change signal", %{change: change} do
      assert SignalHelpers.match_signal?(change, :change)
    end

    test "matches submit signal", %{submit: submit} do
      assert SignalHelpers.match_signal?(submit, :submit)
    end

    test "does not match different signal type", %{click: click} do
      refute SignalHelpers.match_signal?(click, :change)
      refute SignalHelpers.match_signal?(click, :submit)
    end

    test "returns false for nil signal" do
      refute SignalHelpers.match_signal?(nil, :click)
    end
  end

  describe "build_state_update/3" do
    setup do
      {:ok, signal1} = SignalHelpers.build_signal(:click, %{email: "test@example.com"})
      {:ok, signal2} = SignalHelpers.build_signal(:change, %{value: "new"})

      {:ok, signal3} =
        SignalHelpers.build_signal(:submit, %{email: "test@example.com", other: "ignored"})

      {:ok, signal4} = SignalHelpers.build_signal(:click, %{other: "value"})
      {:ok, signal5} = SignalHelpers.build_signal(:click, %{value: "test"})
      {:ok, signal6} = SignalHelpers.build_signal(:change, %{value: "test", count: 5})

      %{
        signal1: signal1,
        signal2: signal2,
        signal3: signal3,
        signal4: signal4,
        signal5: signal5,
        signal6: signal6
      }
    end

    test "returns handler payload when signal is nil" do
      handler = {:save, %{form_id: :login}}
      result = SignalHelpers.build_state_update(handler, nil)
      assert result == %{form_id: :login}
    end

    test "merges handler payload with signal data", %{signal1: signal1} do
      handler = {:save, %{form_id: :login}}

      result = SignalHelpers.build_state_update(handler, signal1)

      assert result.form_id == :login
      assert result.email == "test@example.com"
    end

    test "signal data overrides handler payload on conflict", %{signal2: signal2} do
      handler = {:save, %{form_id: :login, value: "old"}}

      result = SignalHelpers.build_state_update(handler, signal2)

      # Signal data takes precedence
      assert result.value == "new"
      assert result.form_id == :login
    end

    test "extracts specific key from signal data", %{signal3: signal3} do
      handler = {:save, %{form_id: :login}}

      result = SignalHelpers.build_state_update(handler, signal3, :email)

      assert result.form_id == :login
      assert result.email == "test@example.com"
      refute Map.has_key?(result, :other)
    end

    test "handles nil signal value for merge key", %{signal4: signal4} do
      handler = {:save, %{form_id: :login}}

      result = SignalHelpers.build_state_update(handler, signal4, :email)

      # Email not in signal, so not added
      assert result == %{form_id: :login}
    end

    test "handles atom handler with no payload", %{signal5: signal5} do
      handler = :save

      result = SignalHelpers.build_state_update(handler, signal5)

      assert result == %{value: "test"}
    end

    test "handles empty handler payload with signal data", %{signal6: signal6} do
      handler = {:save, %{}}

      result = SignalHelpers.build_state_update(handler, signal6)

      assert result == %{value: "test", count: 5}
    end
  end

  describe "integration scenarios" do
    test "complete button click workflow" do
      # Handler definition from DSL
      handler = {:save_form, %{form_id: :login}}

      # Build signal that would be emitted on click
      {:ok, signal} = SignalHelpers.click_signal(:submit_btn)

      # Extract state update
      state_update = SignalHelpers.build_state_update(handler, signal)

      assert state_update.form_id == :login
      assert state_update.button_id == :submit_btn
    end

    test "complete input change workflow" do
      handler = {:update_email, %{}}

      # Build signal for input change
      {:ok, signal} = SignalHelpers.change_signal(:email_input, "new@email.com")

      # Build state update with value extraction (only extracts :value from signal)
      state_update = SignalHelpers.build_state_update(handler, signal, :value)

      # When using merge_key, only that key is extracted from signal data
      assert state_update.value == "new@email.com"
      # input_id is not included because we specified :value as the merge key

      # Without merge key, all signal data is included
      state_update_full = SignalHelpers.build_state_update(handler, signal)
      assert state_update_full.value == "new@email.com"
      assert state_update_full.input_id == :email_input
    end

    test "form submission with multiple fields" do
      handler = {:submit, %{}}

      form_data = %{
        email: "test@example.com",
        password: "secret",
        remember_me: true
      }

      {:ok, signal} = SignalHelpers.submit_signal(:login_form, form_data)

      state_update = SignalHelpers.build_state_update(handler, signal)

      assert state_update.form_id == :login_form
      assert state_update.email == "test@example.com"
      assert state_update.password == "secret"
      assert state_update.remember_me == true
    end

    test "matching and extracting from multiple signal types" do
      {:ok, click} = SignalHelpers.click_signal(:btn1)
      {:ok, change} = SignalHelpers.change_signal(:input1, "value")
      {:ok, submit} = SignalHelpers.submit_signal(:form1)

      assert SignalHelpers.match_signal?(click, :click)
      refute SignalHelpers.match_signal?(click, :change)

      assert SignalHelpers.match_signal?(change, :change)
      assert SignalHelpers.match_signal?(submit, :submit)

      assert SignalHelpers.extract_payload(click, :button_id) == :btn1
      assert SignalHelpers.extract_payload(change, :value) == "value"
      assert SignalHelpers.extract_payload(submit, :form_id) == :form1
    end
  end

  describe "validate_payload/1" do
    test "accepts valid small payload" do
      assert SignalHelpers.validate_payload(%{button_id: :save_btn}) == :ok
    end

    test "accepts payload with various data types" do
      payload = %{
        string: "test",
        integer: 42,
        float: 3.14,
        atom: :value,
        boolean: true,
        nil: nil
      }

      assert SignalHelpers.validate_payload(payload) == :ok
    end

    test "accepts nested maps within depth limit" do
      payload = %{
        level1: %{
          level2: %{
            level3: %{value: "ok"}
          }
        }
      }

      assert SignalHelpers.validate_payload(payload) == :ok
    end

    test "accepts strings within length limit" do
      payload = %{data: String.duplicate("a", 999)}

      assert SignalHelpers.validate_payload(payload) == :ok
    end

    test "returns :invalid_payload for non-map payloads" do
      assert SignalHelpers.validate_payload("not a map") == {:error, :invalid_payload}
      assert SignalHelpers.validate_payload(123) == {:error, :invalid_payload}
      assert SignalHelpers.validate_payload(nil) == {:error, :invalid_payload}
    end

    test "returns :payload_too_large for large payloads" do
      # Create a payload larger than 10KB
      large_string = String.duplicate("a", 11_000)
      payload = %{data: large_string}

      assert SignalHelpers.validate_payload(payload) == {:error, :payload_too_large}
    end

    test "returns :payload_too_deep for deeply nested payloads" do
      # Create a payload 11 levels deep (max is 10)
      payload =
        1..11
        |> Enum.reduce(%{deep: "value"}, fn _, acc ->
          %{level: acc}
        end)

      assert SignalHelpers.validate_payload(payload) == {:error, :payload_too_deep}
    end

    test "returns :string_too_long for strings exceeding limit" do
      payload = %{data: String.duplicate("a", 1_001)}

      assert SignalHelpers.validate_payload(payload) == {:error, :string_too_long}
    end

    test "checks string lengths in nested payloads" do
      payload = %{
        level1: %{
          level2: %{
            data: String.duplicate("a", 1_001)
          }
        }
      }

      assert SignalHelpers.validate_payload(payload) == {:error, :string_too_long}
    end
  end

  describe "build_signal/3 with payload validation" do
    test "builds signal when payload is valid" do
      assert {:ok, signal} = SignalHelpers.build_signal(:click, %{button_id: :save})
      assert signal.type == "unified.button.clicked"
    end

    test "returns error when payload is too large" do
      large_payload = %{data: String.duplicate("a", 11_000)}

      assert {:error, :payload_too_large} =
               SignalHelpers.build_signal(:click, large_payload)
    end

    test "returns error when payload is too deep" do
      deep_payload =
        1..11
        |> Enum.reduce(%{deep: "value"}, fn _, acc ->
          %{level: acc}
        end)

      assert {:error, :payload_too_deep} =
               SignalHelpers.build_signal(:click, deep_payload)
    end

    test "returns error when string is too long" do
      assert {:error, :string_too_long} =
               SignalHelpers.build_signal(:click, %{data: String.duplicate("a", 1_001)})
    end

    test "can skip validation with validate: false option" do
      large_payload = %{data: String.duplicate("a", 11_000)}

      assert {:ok, _signal} =
               SignalHelpers.build_signal(:click, large_payload, validate: false)
    end
  end
end
