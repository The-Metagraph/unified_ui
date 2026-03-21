defmodule Unified.SpecCompliance.OutputTest do
  use ExUnit.Case, async: true

  alias Unified.SpecCompliance.Output

  test "renders blocking and waived requirement sections in text output" do
    report = %{
      kind: :compliance,
      package: "demo",
      status: :pass,
      summary: %{
        findings: 0,
        aliases: 2,
        concrete: 2,
        status_counts: %{verified: 1, waived: 3, planned: 0, implemented: 0},
        blocking_requirement_ids: ["demo.package.blocked"],
        waived_requirement_ids: [
          "demo.package.one",
          "demo.package.two",
          "demo.package.two.alias"
        ],
        waived_source_requirement_ids: ["demo.package.one", "demo.package.two"]
      },
      findings: []
    }

    output = Output.render(report, :text)

    assert output =~ "Blocking Requirements (1):"
    assert output =~ "demo.package.blocked"
    assert output =~ "Waived Requirements (2 source, 3 effective):"
    assert output =~ "demo.package.one"
    assert output =~ "demo.package.two"
  end

  test "includes waived requirement identifiers in json output" do
    report = %{
      kind: :compliance,
      package: "demo",
      status: :pass,
      summary: %{
        findings: 0,
        aliases: 0,
        concrete: 1,
        status_counts: %{verified: 0, waived: 1, planned: 0, implemented: 0},
        blocking_requirement_ids: [],
        waived_requirement_ids: ["demo.package.one"],
        waived_source_requirement_ids: ["demo.package.one"]
      },
      findings: [],
      results: [],
      manifests: %{}
    }

    payload =
      report
      |> Output.render(:json)
      |> JSON.decode!()

    assert payload["summary"]["waived_requirement_ids"] == ["demo.package.one"]
    assert payload["summary"]["waived_source_requirement_ids"] == ["demo.package.one"]
  end
end
