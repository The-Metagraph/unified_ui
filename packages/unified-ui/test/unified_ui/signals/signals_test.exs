defmodule UnifiedUi.SignalsTest do
  use ExUnit.Case

  alias UnifiedUi.Signals
  alias Jido.Signal

  describe "standard_signals/0" do
    test "returns list of all standard signal names" do
      signals = Signals.standard_signals()

      assert :click in signals
      assert :change in signals
      assert :submit in signals
      assert :focus in signals
      assert :blur in signals
      assert :select in signals

      assert length(signals) == 6
    end
  end

  describe "signal_type/1" do
    test "returns type string for :click" do
      assert Signals.signal_type(:click) == "unified.button.clicked"
    end

    test "returns type string for :change" do
      assert Signals.signal_type(:change) == "unified.input.changed"
    end

    test "returns type string for :submit" do
      assert Signals.signal_type(:submit) == "unified.form.submitted"
    end

    test "returns type string for :focus" do
      assert Signals.signal_type(:focus) == "unified.element.focused"
    end

    test "returns type string for :blur" do
      assert Signals.signal_type(:blur) == "unified.element.blurred"
    end

    test "returns type string for :select" do
      assert Signals.signal_type(:select) == "unified.item.selected"
    end

    test "returns error for unknown signal" do
      assert Signals.signal_type(:unknown) == {:error, :unknown_signal}
    end
  end

  describe "create/3" do
    test "creates a signal from standard signal name" do
      assert {:ok, signal} = Signals.create(:click, %{button_id: :my_btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data == %{button_id: :my_btn}
      assert signal.source == "/unified_ui"
      assert is_binary(signal.id)
    end

    test "creates a signal without payload" do
      assert {:ok, signal} = Signals.create(:click)

      assert signal.data == %{}
      assert signal.type == "unified.button.clicked"
    end

    test "creates a signal with custom source" do
      assert {:ok, signal} = Signals.create(:click, %{}, source: "/my/app")

      assert signal.source == "/my/app"
    end

    test "creates a signal with subject" do
      assert {:ok, signal} = Signals.create(:click, %{}, subject: "my-button")

      assert signal.subject == "my-button"
    end

    test "creates a signal with custom id" do
      assert {:ok, signal} = Signals.create(:click, %{}, id: "custom-id-123")

      assert signal.id == "custom-id-123"
    end

    test "creates a signal from custom type string" do
      assert {:ok, signal} = Signals.create("myapp.custom.event", %{value: 123})

      assert signal.type == "myapp.custom.event"
      assert signal.data == %{value: 123}
    end

    test "returns error for unknown signal name" do
      assert Signals.create(:unknown, %{}) == {:error, :unknown_signal}
    end
  end

  describe "create!/3" do
    test "returns signal on success" do
      signal = Signals.create!(:click, %{button_id: :btn})

      assert signal.type == "unified.button.clicked"
      assert signal.data == %{button_id: :btn}
    end

    test "raises on invalid signal name" do
      assert_raise UnifiedUi.Errors.InvalidSignalError, fn ->
        Signals.create!(:unknown, %{})
      end
    end
  end

  describe "valid_type/1" do
    test "accepts valid signal type strings" do
      assert Signals.valid_type("unified.button.clicked") == :ok
      assert Signals.valid_type("unified.input.changed") == :ok
      assert Signals.valid_type("unified.form.submitted") == :ok
      assert Signals.valid_type("myapp.custom.event") == :ok
    end

    test "rejects invalid type strings" do
      assert Signals.valid_type("invalid") == {:error, :invalid_type_format}
      assert Signals.valid_type("Invalid.Case") == {:error, :invalid_type_format}
      assert Signals.valid_type(nil) == {:error, :invalid_type_format}
      assert Signals.valid_type(:atom) == {:error, :invalid_type_format}
      assert Signals.valid_type("") == {:error, :invalid_type_format}
    end
  end

  describe "integration" do
    test "standard signals can all be created" do
      for name <- Signals.standard_signals() do
        assert {:ok, signal} = Signals.create(name, %{})
        assert is_binary(signal.id)
        assert signal.source == "/unified_ui"
      end
    end

    test "can use Jido.Signal.new directly for custom signals" do
      assert {:ok, signal} =
               Signal.new(%{
                 type: "myapp.custom.event",
                 data: %{value: 123},
                 source: "/my/app"
               })

      assert signal.type == "myapp.custom.event"
      assert signal.data == %{value: 123}
    end
  end
end
