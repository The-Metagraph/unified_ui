defmodule UnifiedUi.DocsComplianceTest do
  @moduledoc """
  Documentation coverage checks for application modules.
  """

  use ExUnit.Case, async: true

  test "all application modules provide moduledoc entries" do
    missing = modules_missing_moduledoc()

    assert missing == [],
           "Modules missing moduledoc entries:\n#{Enum.map_join(missing, "\n", &inspect/1)}"
  end

  test "all public functions and macros provide doc entries" do
    missing = functions_missing_doc()

    assert missing == [],
           "Functions/macros missing @doc entries:\n" <>
             Enum.map_join(missing, "\n", fn {module, name, arity} ->
               "#{inspect(module)}.#{name}/#{arity}"
             end)
  end

  defp app_modules do
    {:ok, modules} = :application.get_key(:unified_ui, :modules)
    modules
  end

  defp modules_missing_moduledoc do
    for module <- app_modules(),
        {:docs_v1, _, _, _, module_doc, _, _} <- [Code.fetch_docs(module)],
        module_doc == :none do
      module
    end
  end

  defp functions_missing_doc do
    for module <- app_modules(),
        {:docs_v1, _, _, _, _module_doc, _, entries} <- [Code.fetch_docs(module)],
        {{kind, _line, name, arity}, _anno, _signature, doc, _meta} <- entries,
        kind in [:function, :macro],
        doc == :none do
      {module, name, arity}
    end
  end
end
