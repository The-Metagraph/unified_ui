defmodule UnifiedUi.Adapters.EventTest do
  @moduledoc """
  Tests for UnifiedUi.Adapters.Event
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Event
  alias UnifiedIUR.Widgets

  describe "to_signal/3" do
    test "creates click signal with element ID" do
      signal = Event.to_signal(:click, :submit_button, %{})

      assert signal == {:click, %{element_id: :submit_button}}
    end

    test "creates signal with additional payload" do
      signal = Event.to_signal(:change, :email_input, %{value: "test@example.com"})

      assert signal == {:change, %{element_id: :email_input, value: "test@example.com"}}
    end

    test "creates signal with timestamp" do
      signal = Event.to_signal(:key_down, :main, %{key: :enter})

      assert {:key_down, payload} = signal
      assert payload.element_id == :main
      assert payload.key == :enter
    end
  end

  describe "get_handler/2" do
    test "extracts on_click handler from button" do
      button = %Widgets.Button{id: :submit, on_click: :submit_form}

      assert {:ok, :submit_form} = Event.get_handler(button, :click)
    end

    test "extracts tuple handler from button" do
      button = %Widgets.Button{id: :submit, on_click: {:submit, %{data: "value"}}}

      assert {:ok, {:submit, %{data: "value"}}} = Event.get_handler(button, :click)
    end

    test "returns error for non-existent handler" do
      button = %Widgets.Button{id: :submit}

      assert :error = Event.get_handler(button, :click)
    end

    test "returns error for wrong event type" do
      button = %Widgets.Button{id: :submit, on_click: :submit}

      assert :error = Event.get_handler(button, :change)
    end

    test "extracts on_change handler from text input" do
      input = %Widgets.TextInput{id: :email, on_change: :email_changed}

      assert {:ok, :email_changed} = Event.get_handler(input, :change)
    end

    test "extracts on_submit handler from text input" do
      input = %Widgets.TextInput{id: :search, on_submit: :search_performed}

      assert {:ok, :search_performed} = Event.get_handler(input, :submit)
    end
  end

  describe "build_signal/3" do
    test "builds signal from button element" do
      button = %Widgets.Button{id: :submit, on_click: :submit_form}

      assert {:ok, signal} = Event.build_signal(button, :click, %{})
      assert signal == {:submit_form, %{element_id: :submit}}
    end

    test "builds signal with payload from handler" do
      button = %Widgets.Button{
        id: :submit,
        on_click: {:submit, %{form_id: :login}}
      }

      assert {:ok, signal} = Event.build_signal(button, :click, %{})
      assert {:submit, payload} = signal
      assert payload.element_id == :submit
      assert payload.form_id == :login
    end

    test "merges payload with handler payload" do
      button = %Widgets.Button{
        id: :submit,
        on_click: {:submit, %{action: "save"}}
      }

      assert {:ok, signal} = Event.build_signal(button, :click, %{timestamp: 123})
      assert {:submit, payload} = signal
      assert payload.element_id == :submit
      assert payload.action == "save"
      assert payload.timestamp == 123
    end

    test "returns error when element has no ID" do
      button = %Widgets.Button{on_click: :submit}

      assert :error = Event.build_signal(button, :click, %{})
    end

    test "returns error when no handler for event type" do
      button = %Widgets.Button{id: :submit}

      assert :error = Event.build_signal(button, :click, %{})
    end

    test "builds signal from text input change" do
      input = %Widgets.TextInput{
        id: :email,
        on_change: :email_changed
      }

      assert {:ok, signal} = Event.build_signal(input, :change, %{value: "test"})
      assert signal == {:email_changed, %{element_id: :email, value: "test"}}
    end

    test "builds signal from text input submit" do
      input = %Widgets.TextInput{
        id: :search,
        on_submit: :do_search
      }

      assert {:ok, signal} = Event.build_signal(input, :submit, %{})
      assert signal == {:do_search, %{element_id: :search}}
    end
  end

  describe "normalize_payload/1" do
    test "adds element_id if missing" do
      payload = Event.normalize_payload(%{value: "test"})

      assert payload.element_id == :unknown
      assert payload.value == "test"
    end

    test "preserves existing element_id" do
      payload = Event.normalize_payload(%{element_id: :button, value: "test"})

      assert payload.element_id == :button
      assert payload.value == "test"
    end

    test "adds timestamp if missing" do
      payload = Event.normalize_payload(%{element_id: :button})

      assert is_integer(payload.timestamp)
      assert payload.element_id == :button
    end

    test "preserves existing timestamp" do
      payload = Event.normalize_payload(%{element_id: :button, timestamp: 999})

      assert payload.timestamp == 999
    end
  end

  describe "dispatch/2" do
    test "sends signal to target process" do
      parent = self()
      signal = {:click, %{element_id: :button}}

      assert :ok = Event.dispatch(signal, parent)

      assert_receive ^signal
    end

    test "returns error for invalid target" do
      signal = {:click, %{element_id: :button}}

      assert {:error, :invalid_target} = Event.dispatch(signal, :nonexistent)
    end
  end

  describe "broadcast/2" do
    test "sends signal to multiple targets" do
      parent = self()
      child = spawn(fn -> :timer.sleep(1000) end)
      signal = {:update, %{data: 1}}

      assert {:ok, 2} = Event.broadcast(signal, [parent, child])

      assert_receive ^signal
    end

    test "returns error count for failed sends" do
      parent = self()
      signal = {:update, %{data: 1}}

      # Mix of valid and invalid
      result = Event.broadcast(signal, [parent, :nonexistent, :also_invalid])

      assert {:error, 2} = result
      assert_receive ^signal
    end
  end

  describe "dispatcher/2" do
    test "creates dispatcher function" do
      button = %Widgets.Button{id: :submit, on_click: :submit_form}
      dispatch_fn = Event.dispatcher(button, :click)

      assert is_function(dispatch_fn, 1)

      signal = dispatch_fn.(%{timestamp: 123})
      assert signal == {:submit_form, %{element_id: :submit, timestamp: 123}}
    end

    test "dispatcher returns nil for no handler" do
      button = %Widgets.Button{id: :submit}
      dispatch_fn = Event.dispatcher(button, :click)

      assert is_function(dispatch_fn, 1)

      assert dispatch_fn.(%{}) == nil
    end
  end

  describe "validate_signal/1" do
    test "validates well-formed signal" do
      signal = {:click, %{element_id: :button}}

      assert :ok = Event.validate_signal(signal)
    end

    test "returns error for missing element_id" do
      signal = {:click, %{other: "data"}}

      assert {:error, :missing_element_id} = Event.validate_signal(signal)
    end

    test "returns error for invalid format" do
      assert {:error, :invalid_format} = Event.validate_signal(:not_a_tuple)
      assert {:error, :invalid_format} = Event.validate_signal({:only_one})
      assert {:error, :invalid_format} = Event.validate_signal({:click, :not_a_map})
    end
  end

  describe "extract_metadata/1" do
    test "extracts coordinates" do
      event = %{x: 10, y: 20, time: 123}

      metadata = Event.extract_metadata(event)

      assert metadata.x == 10
      assert metadata.y == 20
    end

    test "maps ctrl to control" do
      event = %{ctrl: true}

      metadata = Event.extract_metadata(event)

      assert metadata.ctrl == true
    end

    test "extracts shift modifier" do
      event = %{shift: true}

      metadata = Event.extract_metadata(event)

      assert metadata.shift == true
    end

    test "extracts timestamp from time field" do
      event = %{time: 123_456}

      metadata = Event.extract_metadata(event)

      assert metadata.timestamp == 123_456
    end

    test "handles empty map" do
      metadata = Event.extract_metadata(%{})

      assert metadata == %{}
    end

    test "extracts multiple fields" do
      event = %{x: 10, y: 20, ctrl: true, shift: false, time: 123_456}

      metadata = Event.extract_metadata(event)

      assert metadata.x == 10
      assert metadata.y == 20
      assert metadata.ctrl == true
      assert metadata.shift == false
      assert metadata.timestamp == 123_456
    end
  end
end
