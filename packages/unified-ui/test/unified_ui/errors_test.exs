defmodule UnifiedUi.ErrorsTest do
  @moduledoc """
  Tests for the UnifiedUi.Errors module.

  These tests verify that custom error types work correctly
  and provide helpful error messages.
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Errors

  describe "InvalidSignalError" do
    test "can be raised with signal name" do
      assert_raise Errors.InvalidSignalError, "Invalid signal name: :invalid", fn ->
        raise Errors.InvalidSignalError, signal_name: :invalid
      end
    end

    test "can be raised with signal name and type" do
      assert_raise Errors.InvalidSignalError, ~r/Invalid signal: :invalid/, fn ->
        raise Errors.InvalidSignalError,
          signal_name: :invalid,
          signal_type: "unified.invalid.action"
      end
    end

    test "can be raised with just signal type" do
      assert_raise Errors.InvalidSignalError, ~r/Invalid signal/, fn ->
        raise Errors.InvalidSignalError, signal_type: "unified.unknown.action"
      end
    end

    test "exception struct contains all fields" do
      exception = Errors.InvalidSignalError.exception(signal_name: :test)

      assert exception.signal_name == :test
      assert is_binary(exception.message)
    end
  end

  describe "InvalidStyleError" do
    test "can be raised with style field and value" do
      assert_raise Errors.InvalidStyleError, ~r/Invalid style value for :fg/, fn ->
        raise Errors.InvalidStyleError, style_field: :fg, value: :not_a_color
      end
    end

    test "can be raised with just style field" do
      assert_raise Errors.InvalidStyleError, "Invalid style field: :invalid", fn ->
        raise Errors.InvalidStyleError, style_field: :invalid
      end
    end

    test "can be raised with no arguments" do
      assert_raise Errors.InvalidStyleError, "Invalid style attribute", fn ->
        raise Errors.InvalidStyleError
      end
    end

    test "exception struct contains all fields" do
      exception = Errors.InvalidStyleError.exception(style_field: :fg, value: :red)

      assert exception.style_field == :fg
      assert exception.value == :red
      assert is_binary(exception.message)
    end
  end

  describe "DslError" do
    test "can be raised with DSL entity and reason" do
      assert_raise Errors.DslError, ~r/DSL error in :state.*Invalid attribute/, fn ->
        raise Errors.DslError, dsl_entity: :state, reason: "Invalid attribute"
      end
    end

    test "can be raised with just DSL entity" do
      assert_raise Errors.DslError, "DSL error in entity: :widget", fn ->
        raise Errors.DslError, dsl_entity: :widget
      end
    end

    test "can be raised with just reason" do
      assert_raise Errors.DslError, "DSL error in nil: Compilation failed", fn ->
        raise Errors.DslError, reason: "Compilation failed"
      end
    end

    test "exception struct contains all fields" do
      exception = Errors.DslError.exception(dsl_entity: :state, reason: "test")

      assert exception.dsl_entity == :state
      assert exception.reason == "test"
      assert is_binary(exception.message)
    end
  end

  describe "normalize/1" do
    test "returns {:error, reason} tuple for error tuples" do
      assert Errors.normalize({:error, :not_found}) == {:error, :not_found}
    end

    test "wraps bare values in {:error, ...} tuple" do
      assert Errors.normalize(:not_found) == {:error, :not_found}
      assert Errors.normalize("error message") == {:error, "error message"}
    end

    test "handles error from Exceptions" do
      result = Errors.normalize(%ArgumentError{message: "bad arg"})
      assert {:error, _} = result
    end

    test "passes through existing {:error, ...} tuples unchanged" do
      error = {:error, %{field: "value"}}
      assert Errors.normalize(error) == error
    end
  end

  describe "Signals.create! uses custom exception" do
    test "create! raises InvalidSignalError for unknown signals" do
      assert_raise Errors.InvalidSignalError, ~r/Invalid signal name: :unknown/, fn ->
        UnifiedUi.Signals.create!(:unknown, %{})
      end
    end

    test "create! works for valid signals" do
      signal = UnifiedUi.Signals.create!(:click, %{button_id: :test})

      assert signal.type == "unified.button.clicked"
      assert signal.data.button_id == :test
    end
  end
end
