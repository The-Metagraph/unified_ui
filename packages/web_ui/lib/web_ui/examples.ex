defmodule WebUi.Examples do
  @moduledoc """
  Maintained foundational examples for direct-native and canonical `web_ui`
  review workflows.
  """

  alias WebUi.Examples.{
    CanonicalFoundationalScreen,
    FoundationalContinuity,
    NativeFoundationalScreen
  }

  @spec catalog() :: [map()]
  def catalog do
    [
      NativeFoundationalScreen.metadata(),
      CanonicalFoundationalScreen.metadata(),
      FoundationalContinuity.metadata()
    ]
  end

  @spec native_foundational() :: module()
  def native_foundational, do: NativeFoundationalScreen

  @spec canonical_foundational() :: module()
  def canonical_foundational, do: CanonicalFoundationalScreen

  @spec foundational_continuity() :: module()
  def foundational_continuity, do: FoundationalContinuity
end
