defmodule UnifiedUi.RepeatedCollectionAuthoringTest do
  use ExUnit.Case, async: true

  alias Spark.Dsl.Extension
  alias UnifiedUi.{Compiler, Export, Info, Tooling}

  defmodule ArtifactCollectionSurface do
    use UnifiedUi.Dsl

    identity do
      id(:artifact_collection_surface)
      authored_ref([:examples, :artifact_collection_surface])
    end

    composition do
      root(:artifact_collection_root)
      mode(:screen)

      repeated_collection :artifact_rows do
        collection_source(binding_ref(:artifacts))
        item_alias(:artifact)
        index_alias(:row)
        key_path([:id])
        empty_state("No artifacts")

        row_template :artifact_row_template do
          gap(:sm)

          template_children([
            %{
              kind: :artifact_row,
              id: :artifact_record,
              title: "Artifact",
              artifact: row_value([:record], alias: :artifact),
              status: :ready
            },
            %{
              kind: :list_item_multi_column,
              id: :artifact_summary,
              label: "Artifact",
              columns: row_value([:columns], alias: :artifact),
              value: row_index(alias: :row),
              status: :ready,
              interaction_refs: [:open_artifact]
            }
          ])
        end
      end
    end
  end

  defmodule EquivalentArtifactCollectionSurface do
    use UnifiedUi.Dsl

    identity do
      id(:equivalent_artifact_collection_surface)
      authored_ref([:examples, :equivalent_artifact_collection_surface])
    end

    composition do
      root(:equivalent_artifact_collection_root)
      mode(:screen)

      repeated_collection :artifact_rows do
        collection_source(binding_ref(:artifacts))
        item_alias(:artifact)
        index_alias(:row)
        key_path([:id])
        empty_state("No artifacts")

        row_template :artifact_row_template do
          gap(:sm)

          template_children([
            %{
              kind: :artifact_row,
              id: :artifact_record,
              title: "Artifact",
              artifact: row_value([:record], alias: :artifact),
              status: :ready
            },
            %{
              kind: :list_item_multi_column,
              id: :artifact_summary,
              label: "Artifact",
              columns: row_value([:columns], alias: :artifact),
              value: row_index(alias: :row),
              status: :ready,
              interaction_refs: [:open_artifact]
            }
          ])
        end
      end
    end
  end

  test "builds portable row-scope helper descriptors" do
    assert UnifiedUi.Dsl.Helpers.row_value([:artifact, :title]) == %{
             kind: :row_value,
             path: [:artifact, :title]
           }

    assert UnifiedUi.Dsl.Helpers.row_value(:status, alias: :artifact) == %{
             kind: :row_value,
             path: [:status],
             alias: :artifact
           }

    assert UnifiedUi.Dsl.Helpers.row_index(alias: :row) == %{kind: :row_index, alias: :row}

    assert UnifiedUi.Dsl.Helpers.row_key(:id) == %{kind: :row_key, path: [:id]}
  end

  test "stores repeated collection authoring shape with one row template" do
    [collection] = Extension.get_entities(ArtifactCollectionSurface, [:composition])

    assert {collection.family, collection.kind} == {:collection, :repeated_collection}
    assert collection.collection_source == %{kind: :binding_ref, id: :artifacts}
    assert collection.item_alias == :artifact
    assert collection.index_alias == :row
    assert collection.key_path == [:id]
    assert collection.empty_state == "No artifacts"

    assert [%{family: :layout, kind: :row, id: :artifact_row_template}] = collection.children
  end

  test "summarizes repeated collection fields and row-scope references" do
    assert UnifiedUi.Info.composition_summary(ArtifactCollectionSurface) == [
             %{
               id: :artifact_rows,
               family: :collection,
               kind: :repeated_collection,
               collection_source: %{kind: :binding_ref, id: :artifacts},
               item_alias: :artifact,
               index_alias: :row,
               key_path: [:id],
               empty_state: "No artifacts",
               children: [
                 %{
                   id: :artifact_row_template,
                   family: :layout,
                   kind: :row,
                   template_children: [
                     %{
                       kind: :artifact_row,
                       id: :artifact_record,
                       title: "Artifact",
                       artifact: %{kind: :row_value, path: [:record], alias: :artifact},
                       status: :ready
                     },
                     %{
                       kind: :list_item_multi_column,
                       id: :artifact_summary,
                       label: "Artifact",
                       columns: %{kind: :row_value, path: [:columns], alias: :artifact},
                       value: %{kind: :row_index, alias: :row},
                       status: :ready,
                       interaction_refs: [:open_artifact]
                     }
                   ]
                 }
               ]
             }
           ]
  end

  test "exposes repeated collection details through authoring inspection and export" do
    authoring = Info.authoring_surface_summary(ArtifactCollectionSurface)

    assert authoring.families == [:collection, :layout]

    assert Enum.map(authoring.widgets, &Map.take(&1, [:id, :family, :kind, :required_fields])) ==
             [
               %{
                 id: :artifact_rows,
                 family: :collection,
                 kind: :repeated_collection,
                 required_fields: [:collection_source, :key_path]
               },
               %{id: :artifact_row_template, family: :layout, kind: :row}
             ]

    assert authoring.repeated_collections == [
             %{
               id: :artifact_rows,
               collection_source: %{kind: :binding_ref, id: :artifacts},
               item_alias: :artifact,
               index_alias: :row,
               key_path: [:id],
               empty_state: "No artifacts",
               child_template: %{
                 id: :artifact_row_template,
                 family: :layout,
                 kind: :row,
                 template_children: [
                   %{
                     kind: :artifact_row,
                     id: :artifact_record,
                     title: "Artifact",
                     artifact: %{kind: :row_value, path: [:record], alias: :artifact},
                     status: :ready
                   },
                   %{
                     kind: :list_item_multi_column,
                     id: :artifact_summary,
                     label: "Artifact",
                     columns: %{kind: :row_value, path: [:columns], alias: :artifact},
                     value: %{kind: :row_index, alias: :row},
                     status: :ready,
                     interaction_refs: [:open_artifact]
                   }
                 ]
               }
             }
           ]

    assert {:ok, inspection} = Export.module(ArtifactCollectionSurface, :inspection)
    assert inspection =~ "authored families: [:collection, :layout]"
    assert inspection =~ "repeated collections: [artifact_rows source=%{"
    assert inspection =~ "artifacts"
    assert inspection =~ "aliases={:artifact, :row}"
    assert inspection =~ "key=[:id]"
    assert inspection =~ "row-scope refs:"

    assert {:ok, exported_authoring} = Export.module(ArtifactCollectionSurface, :authoring)
    assert exported_authoring =~ "repeated_collections"
    assert exported_authoring =~ "row_scope_refs"

    assert {:ok, report} = Tooling.inspect_module(ArtifactCollectionSurface)
    assert report.authoring_surface.repeated_collections == authoring.repeated_collections
    assert ".spec/specs/unified-ui/dsl.spec.md" in report.related_specs
    assert ".spec/specs/unified-ui/widgets.spec.md" in report.related_specs
  end

  test "keeps equivalent repeated collection inspection and export output deterministic" do
    assert Info.authoring_surface_summary(ArtifactCollectionSurface) ==
             Info.authoring_surface_summary(EquivalentArtifactCollectionSurface)

    assert Compiler.inspection(ArtifactCollectionSurface).authoring_surface ==
             Compiler.inspection(EquivalentArtifactCollectionSurface).authoring_surface

    assert {:ok, left} = Export.module(ArtifactCollectionSurface, :authoring)
    assert {:ok, right} = Export.module(EquivalentArtifactCollectionSurface, :authoring)
    assert left == right
  end

  test "rejects non-portable repeated collection sources and invalid templates" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_ash_collection)
      end

      composition do
        root(:invalid_ash_collection_root)

        repeated_collection :artifact_rows do
          collection_source(%{kind: :ash_relationship, relationship: :artifacts})
          key_path([:id])

          artifact_row :artifact_template do
            title("Artifact")
            artifact(%{id: "artifact"})
          end
        end
      end
      """,
      "must use a portable collection_source"
    )

    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_multi_template_collection)
      end

      composition do
        root(:invalid_multi_template_collection_root)

        repeated_collection :artifact_rows do
          collection_source(binding_ref(:artifacts))
          key_path([:id])

          artifact_row :first_template do
            title("First")
            artifact(%{id: "first"})
          end

          artifact_row :second_template do
            title("Second")
            artifact(%{id: "second"})
          end
        end
      end
      """,
      "must declare exactly one child template"
    )
  end

  test "rejects row-scope references outside repeated collection templates" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_unscoped_row_ref)
      end

      composition do
        root(:invalid_unscoped_row_ref_root)

        list_item_multi_column :artifact_summary do
          label("Artifact")
          columns(row_value(:columns))
        end
      end
      """,
      "uses row-scope references outside a repeated_collection template"
    )
  end

  defp compile_module(body) do
    module_name = "Generated#{System.unique_integer([:positive])}"

    Code.compile_string("""
    defmodule UnifiedUi.RepeatedCollectionAuthoringTest.#{module_name} do
      use UnifiedUi.Dsl

      #{body}
    end
    """)
  end

  defp assert_compile_dsl_error(body, expected_message) do
    {pid, ref} = spawn_monitor(fn -> compile_module(body) end)

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} ->
        flunk("expected authored module compilation to fail, but it succeeded")

      {:DOWN, ^ref, :process, ^pid, reason} ->
        assert Exception.format_exit(reason) =~ expected_message
    end
  end
end
