defmodule UnifiedUi.Dsl.Verifiers do
  @moduledoc """
  Registry of baseline DSL verifiers for authored `UnifiedUi` modules.
  """

  alias UnifiedUi.Dsl.Verifiers.{
    ValidateCompositionPlacement,
    ValidateAuthoringInvariants,
    ValidateRequiredSections
  }

  @spec all() :: [module()]
  def all do
    [ValidateRequiredSections, ValidateAuthoringInvariants, ValidateCompositionPlacement]
  end
end
