defmodule UnifiedIUR.Constructs do
  @moduledoc """
  Namespace anchor for canonical widget, layout, layering, styling, and theming
  construct families.
  """

  alias UnifiedIUR.{Container, Forms, Widgets}

  @spec modules() :: %{container: module(), forms: module(), widgets: module()}
  def modules do
    %{
      widgets: Widgets,
      container: Container,
      forms: Forms
    }
  end
end
