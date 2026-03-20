defmodule Unified.SpecCompliance do
  @moduledoc """
  Package-scoped plan and implementation compliance checks.
  """

  alias Unified.SpecCompliance.{CI, Compliance, Plancheck, Traceability}

  @type package_name :: String.t()
  @type options :: Keyword.t()
  @type result :: map()

  @spec plancheck(package_name(), options()) :: result()
  def plancheck(package, opts \\ []) when is_binary(package) do
    Plancheck.run(package, opts)
  end

  @spec compliance(package_name(), options()) :: result()
  def compliance(package, opts \\ []) when is_binary(package) do
    Compliance.run(package, opts)
  end

  @spec generate_traceability(package_name(), options()) :: result()
  def generate_traceability(package, opts \\ []) when is_binary(package) do
    Traceability.generate(package, opts)
  end

  @spec ci(options()) :: result()
  def ci(opts \\ []) do
    CI.run(opts)
  end
end
