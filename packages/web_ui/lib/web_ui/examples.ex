defmodule WebUi.Examples do
  @moduledoc """
  Maintained foundational examples for direct-native and canonical `web_ui`
  review workflows.
  """

  alias WebUi.Examples.{
    AdvancedContinuity,
    CanonicalAdvancedOperationsScreen,
    CanonicalFoundationalScreen,
    FoundationalContinuity,
    NativeAdvancedOperationsScreen,
    NativeFoundationalScreen
  }

  @spec catalog() :: [map()]
  def catalog do
    [
      NativeFoundationalScreen.metadata(),
      CanonicalFoundationalScreen.metadata(),
      FoundationalContinuity.metadata(),
      NativeAdvancedOperationsScreen.metadata(),
      CanonicalAdvancedOperationsScreen.metadata(),
      AdvancedContinuity.metadata()
    ]
  end

  @spec native_foundational() :: module()
  def native_foundational, do: NativeFoundationalScreen

  @spec canonical_foundational() :: module()
  def canonical_foundational, do: CanonicalFoundationalScreen

  @spec foundational_continuity() :: module()
  def foundational_continuity, do: FoundationalContinuity

  @spec native_advanced_operations() :: module()
  def native_advanced_operations, do: NativeAdvancedOperationsScreen

  @spec canonical_advanced_operations() :: module()
  def canonical_advanced_operations, do: CanonicalAdvancedOperationsScreen

  @spec advanced_continuity() :: module()
  def advanced_continuity, do: AdvancedContinuity
end
