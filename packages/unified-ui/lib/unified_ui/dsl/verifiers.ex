defmodule UnifiedUi.Dsl.Verifiers do
  @moduledoc """
  Registry of baseline DSL verifiers for authored `UnifiedUi` modules.
  """

  alias UnifiedUi.Dsl.Verifiers.{
    ValidateAuthoringInvariants,
    ValidateRequiredSections
  }

  @spec all() :: [module()]
  def all do
    [ValidateRequiredSections, ValidateAuthoringInvariants]
  end
end
