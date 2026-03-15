defmodule UnifiedUi.Dsl.Extension do
  @moduledoc """
  Spark extension for authored `UnifiedUi` modules.
  """

  alias UnifiedUi.Dsl.SectionRegistry

  use Spark.Dsl.Extension,
    sections: SectionRegistry.sections(),
    imports: [UnifiedUi.Dsl.Helpers],
    module_prefix: [UnifiedUi, Dsl]
end
