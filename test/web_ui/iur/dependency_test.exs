defmodule WebUi.Iur.DependencyTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Layouts
  alias UnifiedIUR.Widgets
  alias WebUi.Iur.Dependency
  alias WebUi.TypedError

  test "unified_iur dependency is pinned to a git ref in mix lock" do
    lock = Mix.Dep.Lock.read()[:unified_iur]
    assert lock != nil

    opts =
      case lock do
        {:git, _url, _rev, opts} when is_list(opts) ->
          opts

        {:git, _url, _rev, _sparse, opts} when is_list(opts) ->
          opts

        other ->
          flunk("unexpected lock format for unified_iur: #{inspect(other)}")
      end

    assert is_binary(Keyword.get(opts, :ref))
    assert String.length(Keyword.fetch!(opts, :ref)) == 40
    refute Keyword.has_key?(opts, :branch)
  end

  test "exposes canonical dependency version and struct compatibility checks" do
    assert is_binary(Dependency.dependency_version())
    assert Dependency.dependency_version() != ""

    assert Dependency.canonical_iur_struct?(%Layouts.VBox{})
    assert Dependency.canonical_iur_struct?(%Widgets.Button{})
    refute Dependency.canonical_iur_struct?(%{type: :vbox})
  end

  test "validates canonical schema markers and fails closed for unsupported markers" do
    version = Dependency.dependency_version()

    assert :ok ==
             Dependency.validate_schema_markers(%{
               schema: "unified_iur",
               schema_source: "pcharbon70/unified_iur",
               schema_version: version
             })

    assert :ok == Dependency.validate_schema_markers(%{})

    assert {:error, %TypedError{} = schema_error} =
             Dependency.validate_schema_markers(%{schema: "other_schema"}, "corr-schema")

    assert schema_error.error_code == "iur.interpreter.unsupported_schema"
    assert schema_error.correlation_id == "corr-schema"

    assert {:error, %TypedError{} = source_error} =
             Dependency.validate_schema_markers(%{schema_source: "unknown/repo"}, "corr-source")

    assert source_error.error_code == "iur.interpreter.unsupported_schema_source"
    assert source_error.correlation_id == "corr-source"

    assert {:error, %TypedError{} = version_error} =
             Dependency.validate_schema_markers(%{schema_version: "0.0.0"}, "corr-version")

    assert version_error.error_code == "iur.interpreter.unsupported_schema_version"
    assert version_error.correlation_id == "corr-version"
  end
end
