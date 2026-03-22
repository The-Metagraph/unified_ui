defmodule WebUi.Info do
  @moduledoc """
  Lightweight package summary helpers.
  """

  @spec package_summary() :: map()
  def package_summary do
    coverage_matrix = WebUi.Examples.coverage_matrix()
    {:ok, release_readiness} = WebUi.Validate.release_readiness(:summary)

    %{
      package: :web_ui,
      namespace: WebUi,
      package_areas: WebUi.package_areas(),
      validation_state: WebUi.Runtime.validation_state(),
      bridge: bridge_summary(),
      style: %{
        primitives: WebUi.Style.primitives(),
        hooks: WebUi.Style.widget_style_hooks()
      },
      theme: %{
        catalog: WebUi.Theme.catalog_ids(),
        default: WebUi.Theme.default_theme().id
      },
      inspection: %{
        helpers: WebUi.Inspection.helpers(),
        continuity_seams: WebUi.Continuity.seams()
      },
      validation: %{
        workflows: WebUi.Tooling.workflows(),
        example_coverage: WebUi.Validate.example_coverage().status,
        runtime_behavior: WebUi.Validate.runtime_behavior().status,
        release_readiness: release_readiness.status
      },
      examples: %{
        total: length(WebUi.Examples.catalog()),
        categories: coverage_matrix.categories |> Map.keys() |> Enum.sort(),
        workflows: coverage_matrix.workflows |> Map.keys() |> Enum.sort(),
        parity_groups: coverage_matrix.parity_groups |> Map.keys() |> Enum.sort()
      },
      tooling: %{
        workflows: WebUi.Tooling.workflows(),
        mix_tasks: WebUi.Tooling.mix_tasks()
      },
      documentation: %{
        guides: WebUi.Tooling.documentation_surface(),
        preview_surfaces: WebUi.Tooling.preview_surfaces()
      }
    }
  end

  @spec renderer_summary() :: map()
  def renderer_summary do
    %{
      accepts: WebUi.Renderer.accepts(),
      supported_kinds: WebUi.Renderer.supported_kinds(),
      responsibilities: WebUi.Renderer.responsibilities()
    }
  end

  @spec widget_summary(WebUi.Widget.t()) :: map()
  def widget_summary(%WebUi.Widget{} = widget) do
    %{
      id: widget.id,
      family: widget.family,
      kind: widget.kind,
      metadata: widget.metadata,
      state: widget.state,
      slots: widget.slots,
      slot_children:
        Map.new(widget.slot_children, fn {slot, children} -> {slot, length(children)} end),
      attribute_keys: Map.keys(widget.attributes),
      style_keys: Map.keys(widget.styles),
      event_keys: Map.keys(widget.events)
    }
  end

  @spec bridge_summary() :: map()
  def bridge_summary do
    %{
      boundaries: WebUi.Reference.browser_bridge_boundaries(),
      signal_families: WebUi.Signals.families(),
      frontend_modules: WebUi.Frontend.modules(),
      server_modules: WebUi.Server.modules()
    }
  end
end
