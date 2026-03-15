defmodule UnifiedIUR.Tooling do
  @moduledoc """
  Namespace anchor for package-local tooling and maintainer-oriented helpers.
  """

  alias UnifiedIUR.{Export, Fixtures, Inspect, Validate}

  @spec fixture_catalog() :: [map()]
  def fixture_catalog do
    Fixtures.catalog()
  end

  @spec inspect_fixture(String.t()) :: {:ok, map()} | :error
  def inspect_fixture(id) do
    Inspect.fixture(id)
  end

  @spec export_fixture(String.t(), Export.export_format()) :: {:ok, String.t()} | :error
  def export_fixture(id, format \\ :fixture) do
    Export.fixture(id, format)
  end

  @spec validation_diagnostics(UnifiedIUR.Element.t() | map() | keyword()) :: map()
  def validation_diagnostics(input) do
    Validate.diagnostics(input)
  end

  @spec extension_metadata() :: map()
  def extension_metadata do
    Inspect.extension_metadata()
  end
end
