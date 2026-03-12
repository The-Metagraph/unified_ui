defmodule UnifiedUi.Dsl.FormHelpersTest do
  @moduledoc """
  Tests for the UnifiedUi DSL FormHelpers module.

  These tests verify that:
  - Form data collection works correctly
  - Form input IDs are extracted correctly
  - Form submission signals are built correctly
  - Form validation helpers work as expected
  """

  use ExUnit.Case, async: true

  alias UnifiedUi.Dsl.FormHelpers
  alias UnifiedIUR.Widgets.TextInput

  # Helper to create a mock DSL state
  defp create_dsl_state(widgets_entities) do
    %{
      persist: %{module: TestModule},
      widgets: %{entities: widgets_entities}
    }
  end

  # Helper to create a TextInput entity
  defp create_text_input(id, opts) do
    defaults = [
      __struct__: TextInput,
      id: id,
      value: nil,
      placeholder: nil,
      type: :text,
      on_change: nil,
      on_submit: nil,
      form_id: nil,
      disabled: false,
      style: nil,
      visible: true
    ]

    struct!(TextInput, Keyword.merge(defaults, opts))
  end

  describe "collect_form_data/2" do
    test "collects data from inputs with matching form_id" do
      entities = [
        create_text_input(:email, value: "user@example.com", form_id: :login),
        create_text_input(:password, value: "[REDACTED_TEST_PASSWORD]", form_id: :login),
        create_text_input(:name, value: "John Doe", form_id: :signup)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.collect_form_data(dsl_state, :login)

      assert result == %{email: "user@example.com", password: "[REDACTED]"}
    end

    test "returns empty map when no inputs match form_id" do
      entities = [
        create_text_input(:email, value: "user@example.com", form_id: :login)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.collect_form_data(dsl_state, :signup)

      assert result == %{}
    end

    test "handles nil values in inputs" do
      entities = [
        create_text_input(:email, value: "user@example.com", form_id: :login),
        create_text_input(:password, value: nil, form_id: :login)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.collect_form_data(dsl_state, :login)

      assert result == %{email: "user@example.com", password: "[REDACTED]"}
    end

    test "excludes inputs without form_id" do
      entities = [
        create_text_input(:email, value: "user@example.com", form_id: :login),
        create_text_input(:other, value: "unaffiliated", form_id: nil)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.collect_form_data(dsl_state, :login)

      assert result == %{email: "user@example.com"}
    end

    test "handles multiple forms with different form_ids" do
      entities = [
        create_text_input(:email, value: "user@example.com", form_id: :login),
        create_text_input(:password, value: "[REDACTED_TEST_PASS]", form_id: :login),
        create_text_input(:name, value: "John", form_id: :signup),
        create_text_input(:signup_email, value: "john@example.com", form_id: :signup)
      ]

      dsl_state = create_dsl_state(entities)

      login_data = FormHelpers.collect_form_data(dsl_state, :login)
      signup_data = FormHelpers.collect_form_data(dsl_state, :signup)

      assert login_data == %{email: "user@example.com", password: "[REDACTED]"}
      assert signup_data == %{name: "John", signup_email: "john@example.com"}
    end

    test "handles empty string values" do
      entities = [
        create_text_input(:email, value: "", form_id: :login),
        create_text_input(:password, value: "[REDACTED_EMPTY]", form_id: :login)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.collect_form_data(dsl_state, :login)

      assert result == %{email: "", password: "[REDACTED]"}
    end
  end

  describe "form_input_ids/2" do
    test "returns list of input IDs for a form" do
      entities = [
        create_text_input(:email, form_id: :login),
        create_text_input(:password, form_id: :login),
        create_text_input(:name, form_id: :signup)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.form_input_ids(dsl_state, :login)

      assert result == [:email, :password]
    end

    test "returns empty list when no inputs match form_id" do
      entities = [
        create_text_input(:email, form_id: :login)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.form_input_ids(dsl_state, :signup)

      assert result == []
    end

    test "excludes inputs without form_id" do
      entities = [
        create_text_input(:email, form_id: :login),
        create_text_input(:unaffiliated, form_id: nil)
      ]

      dsl_state = create_dsl_state(entities)

      result = FormHelpers.form_input_ids(dsl_state, :login)

      assert result == [:email]
    end
  end

  describe "build_form_submit_signal/3" do
    test "builds signal with form_id and data" do
      result = FormHelpers.build_form_submit_signal(:login, %{email: "test@example.com"})

      assert result == {:form_submit, %{form_id: :login, data: %{email: "test@example.com"}}}
    end

    test "builds signal with extra payload" do
      result =
        FormHelpers.build_form_submit_signal(:login, %{email: "test@example.com"}, %{
          timestamp: 123_456,
          source: :web
        })

      assert result ==
               {:form_submit,
                %{
                  form_id: :login,
                  data: %{email: "test@example.com"},
                  timestamp: 123_456,
                  source: :web
                }}
    end

    test "extra payload merges with base payload (can override)" do
      result =
        FormHelpers.build_form_submit_signal(:login, %{email: "test@example.com"}, %{
          timestamp: 123_456
        })

      assert result ==
               {:form_submit,
                %{form_id: :login, data: %{email: "test@example.com"}, timestamp: 123_456}}
    end
  end

  describe "validate_required/2" do
    test "returns :ok when all required fields are present and non-empty" do
      form_data = %{email: "test@example.com", password: "[TEST_PASSWORD_VALUE]"}

      result = FormHelpers.validate_required(form_data, [:email, :password])

      assert result == :ok
    end

    test "returns error when required field is missing" do
      form_data = %{email: "test@example.com"}

      result = FormHelpers.validate_required(form_data, [:email, :password])

      assert result == {:error, [:password]}
    end

    test "returns error when required field is empty string" do
      form_data = %{email: "", password: "[TEST_PASS_VALUE]"}

      result = FormHelpers.validate_required(form_data, [:email, :password])

      assert result == {:error, [:email]}
    end

    test "returns error when required field is nil" do
      form_data = %{email: nil, password: "[TEST_PASS_PLACEHOLDER]"}

      result = FormHelpers.validate_required(form_data, [:email, :password])

      assert result == {:error, [:email]}
    end

    test "returns all missing fields when multiple are missing" do
      form_data = %{email: "test@example.com"}

      result = FormHelpers.validate_required(form_data, [:email, :password, :name])

      assert result == {:error, [:password, :name]}
    end

    test "returns :ok when no fields are required" do
      form_data = %{}

      result = FormHelpers.validate_required(form_data, [])

      assert result == :ok
    end
  end

  describe "validate_email/2" do
    test "returns :ok for valid email" do
      form_data = %{email: "user@example.com"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == :ok
    end

    test "returns :ok for valid email with subdomain" do
      form_data = %{email: "user@mail.example.com"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == :ok
    end

    test "returns :ok for valid email with plus addressing" do
      form_data = %{email: "user+tag@example.com"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == :ok
    end

    test "returns error for email without @" do
      form_data = %{email: "invalidemail"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :invalid_format}
    end

    test "returns error for email with only @" do
      form_data = %{email: "@"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :invalid_format}
    end

    test "returns error for email without domain" do
      form_data = %{email: "user@"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :invalid_format}
    end

    test "returns error for email without local part" do
      form_data = %{email: "@example.com"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :invalid_format}
    end

    test "returns error for email without dot in domain" do
      form_data = %{email: "user@localhost"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :invalid_format}
    end

    test "returns error when field is missing" do
      form_data = %{other_field: "value"}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :missing}
    end

    test "returns error when field is nil" do
      form_data = %{email: nil}

      result = FormHelpers.validate_email(form_data, :email)

      assert result == {:error, :missing}
    end
  end

  describe "validate_length/4" do
    test "returns :ok when length is within range" do
      form_data = %{username: "john_doe"}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == :ok
    end

    test "returns :ok when length equals minimum" do
      form_data = %{username: "abc"}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == :ok
    end

    test "returns :ok when length equals maximum" do
      form_data = %{username: "12345678901234567890"}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == :ok
    end

    test "returns :too_short when value is too short" do
      form_data = %{username: "ab"}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == {:error, :too_short}
    end

    test "returns :too_long when value is too long" do
      form_data = %{username: "this_is_a_very_long_username"}

      result = FormHelpers.validate_length(form_data, :username, 3, 10)

      assert result == {:error, :too_long}
    end

    test "returns :ok with no maximum when max is :infinity" do
      form_data = %{username: String.duplicate("a", 1000)}

      result = FormHelpers.validate_length(form_data, :username, 1, :infinity)

      assert result == :ok
    end

    test "returns :too_short with zero minimum" do
      form_data = %{username: ""}

      result = FormHelpers.validate_length(form_data, :username, 1, :infinity)

      assert result == {:error, :too_short}
    end

    test "returns :ok with zero minimum and empty string" do
      form_data = %{username: ""}

      result = FormHelpers.validate_length(form_data, :username, 0, 10)

      assert result == :ok
    end

    test "returns :missing when field is not present" do
      form_data = %{other_field: "value"}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == {:error, :missing}
    end

    test "returns :missing when field is nil" do
      form_data = %{username: nil}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == {:error, :missing}
    end

    test "returns :invalid_type when field is not a string" do
      form_data = %{username: 12_345}

      result = FormHelpers.validate_length(form_data, :username, 3, 20)

      assert result == {:error, :invalid_type}
    end
  end

  describe "validate_format/3" do
    test "returns :ok when value matches predefined pattern" do
      form_data = %{zip: "12345"}

      result = FormHelpers.validate_format(form_data, :zip, :us_zip)

      assert result == :ok
    end

    test "returns :ok when value matches username pattern" do
      form_data = %{username: "john123"}

      result = FormHelpers.validate_format(form_data, :username, :username)

      assert result == :ok
    end

    test "returns :invalid_format when value does not match pattern" do
      form_data = %{zip: "ABCDE"}

      result = FormHelpers.validate_format(form_data, :zip, :us_zip)

      assert result == {:error, :invalid_format}
    end

    test "returns :missing when field is not present" do
      form_data = %{other_field: "value"}

      result = FormHelpers.validate_format(form_data, :zip, :us_zip)

      assert result == {:error, :missing}
    end

    test "returns :missing when field is nil" do
      form_data = %{zip: nil}

      result = FormHelpers.validate_format(form_data, :zip, :us_zip)

      assert result == {:error, :missing}
    end

    test "returns :invalid_type when field is not a string" do
      form_data = %{zip: 12_345}

      result = FormHelpers.validate_format(form_data, :zip, :us_zip)

      assert result == {:error, :invalid_type}
    end

    test "validates username with alphanumeric pattern" do
      form_data = %{username: "john123"}

      result = FormHelpers.validate_format(form_data, :username, :username)

      assert result == :ok
    end

    test "rejects username with special characters" do
      form_data = %{username: "john@123"}

      result = FormHelpers.validate_format(form_data, :username, :username)

      assert result == {:error, :invalid_format}
    end

    test "returns :unknown_pattern for invalid pattern name" do
      form_data = %{field: "value"}

      result = FormHelpers.validate_format(form_data, :field, :not_a_real_pattern)

      assert result == {:error, :unknown_pattern}
    end

    test "validates UUID format" do
      form_data = %{id: "550e8400-e29b-41d4-a716-446655440000"}

      result = FormHelpers.validate_format(form_data, :id, :uuid)

      assert result == :ok
    end

    test "rejects invalid UUID format" do
      form_data = %{id: "not-a-uuid"}

      result = FormHelpers.validate_format(form_data, :id, :uuid)

      assert result == {:error, :invalid_format}
    end

    test "validates slug format" do
      form_data = %{slug: "my-blog-post"}

      result = FormHelpers.validate_format(form_data, :slug, :slug)

      assert result == :ok
    end

    test "rejects invalid slug format" do
      form_data = %{slug: "My_Blog_Post"}

      result = FormHelpers.validate_format(form_data, :slug, :slug)

      assert result == {:error, :invalid_format}
    end
  end

  describe "validate_form/2" do
    test "returns :ok when all validations pass" do
      form_data = %{
        email: "user@example.com",
        password: "[VALID_TEST_PASSWORD]",
        username: "john_doe"
      }

      result =
        FormHelpers.validate_form(form_data, [
          {:required, :email},
          {:required, :password},
          {:email, :email},
          {:length, :password, 8},
          {:length, :username, 3, 20}
        ])

      assert result == :ok
    end

    test "returns map of all errors when multiple validations fail" do
      form_data = %{
        email: "bad-email",
        password: "short"
      }

      result =
        FormHelpers.validate_form(form_data, [
          {:required, :email},
          {:required, :password},
          {:email, :email},
          {:length, :password, 8, :infinity}
        ])

      assert result == {:error, %{email: :invalid_format, password: :too_short}}
    end

    test "returns error for missing required fields" do
      form_data = %{email: "user@example.com"}

      result =
        FormHelpers.validate_form(form_data, [
          {:required, :email},
          {:required, :password},
          {:required, :name}
        ])

      assert result == {:error, %{password: :required, name: :required}}
    end

    test "handles format validation" do
      form_data = %{zip: "ABCDE", phone: "1234567890"}

      result =
        FormHelpers.validate_form(form_data, [
          {:format, :zip, :us_zip},
          {:format, :phone, :phone_intl}
        ])

      assert result == {:error, %{zip: :invalid_format}}
    end

    test "returns :ok for empty validation list" do
      form_data = %{any_field: "any_value"}

      result = FormHelpers.validate_form(form_data, [])

      assert result == :ok
    end

    test "combines different validation types" do
      form_data = %{
        email: "not-an-email",
        password: "short",
        username: "",
        zip: "ABCDE"
      }

      result =
        FormHelpers.validate_form(form_data, [
          {:required, :username},
          {:email, :email},
          {:length, :password, 8},
          {:format, :zip, :us_zip}
        ])

      assert result ==
               {:error,
                %{
                  username: :required,
                  email: :invalid_format,
                  password: :too_short,
                  zip: :invalid_format
                }}
    end
  end
end
