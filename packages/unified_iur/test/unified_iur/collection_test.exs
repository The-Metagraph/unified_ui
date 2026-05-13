defmodule UnifiedIUR.CollectionTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Binding
  alias UnifiedIUR.Collection
  alias UnifiedIUR.Element
  alias UnifiedIUR.Validate
  alias UnifiedIUR.Widgets.Foundational

  test "builds repeated collection constructs with source, aliases, key path, template, and empty state" do
    template =
      Foundational.content(
        [
          {:title,
           Foundational.text("Artifact title",
             id: "artifact-title-template",
             bindings: [Binding.row_value(:artifact, :title)]
           )},
          {:status,
           Foundational.badge("Status",
             id: "artifact-status-template",
             bindings: [Binding.row_style_variant(:artifact, :status)]
           )}
        ],
        id: "artifact-row-template"
      )

    collection =
      Collection.repeated_collection(template,
        id: "artifact-rows",
        source: [
          name: :artifacts,
          path: [:artifacts],
          value: [
            %{id: "artifact-1", title: "artifact.tar", status: :ready},
            %{id: "artifact-2", title: "docs.zip", status: :queued}
          ]
        ],
        item_alias: :artifact,
        index_alias: :artifact_index,
        key_path: [:id],
        row_scope_bindings: [
          Binding.row_key(:artifact, :id),
          Binding.row_index(:artifact_index)
        ],
        empty_state: "No artifacts"
      )

    assert %Element{
             type: :composite,
             kind: :repeated_collection,
             children: [%{slot: :template}, %{slot: :empty_state}],
             attributes: %{
               collection: %{
                 source: %Binding{
                   name: :artifacts,
                   path: [:artifacts],
                   collection?: true,
                   value: [%{id: "artifact-1"}, %{id: "artifact-2"}]
                 },
                 item_alias: :artifact,
                 index_alias: :artifact_index,
                 key_path: [:id],
                 template_slot: :template,
                 empty_state_slot: :empty_state
               },
               row_scope: %{
                 item_alias: :artifact,
                 index_alias: :artifact_index,
                 bindings: [
                   %Binding{source: :row_scope, scope: [:artifact], path: [:id]},
                   %Binding{source: :row_scope, scope: [:artifact_index], path: []}
                 ]
               }
             }
           } = collection

    assert :ok = Validate.element(collection)
  end

  test "builds row-scope binding descriptors for common renderer-independent uses" do
    assert %Binding{
             source: :row_scope,
             scope: [:artifact],
             path: [:title],
             metadata: %{row_alias: :artifact, target: :content, binding_kind: :value}
           } = Binding.row_value(:artifact, :title)

    assert %Binding{
             source: :row_scope,
             scope: [:artifact],
             path: [:status],
             metadata: %{
               row_alias: :artifact,
               target: :interaction_payload,
               binding_kind: :payload
             }
           } = Binding.row_payload(:artifact, :status)

    assert %Binding{
             source: :row_scope,
             scope: [:artifact],
             path: [:selected?],
             metadata: %{target: :selection_state, binding_kind: :selection}
           } = Binding.row_selection(:artifact, :selected?)

    assert %Binding{
             source: :row_scope,
             scope: [:artifact_index],
             path: [],
             metadata: %{binding_kind: :index}
           } = Binding.row_index(:artifact_index)
  end

  test "rejects invalid collection sources, missing templates, duplicate keys, and unavailable row aliases" do
    missing_template =
      Collection.repeated_collection(nil,
        id: "missing-template",
        source: [name: :artifacts, path: [:artifacts]],
        item_alias: :artifact,
        key_path: [:id]
      )

    duplicate_keys =
      Collection.repeated_collection(Foundational.text("Title", id: "title-template"),
        id: "duplicate-keys",
        source: [
          name: :artifacts,
          path: [:artifacts],
          value: [%{id: "artifact-1"}, %{id: "artifact-1"}]
        ],
        item_alias: :artifact,
        key_path: [:id]
      )

    relationship_source =
      Collection.repeated_collection(Foundational.text("Title", id: "relationship-template"),
        id: "relationship-source",
        source: [name: :comments, path: [:comments], relationship: :comments],
        item_alias: :comment,
        key_path: [:id]
      )

    unavailable_alias =
      Collection.repeated_collection(
        Foundational.text("Title",
          id: "bad-alias-title",
          bindings: [Binding.row_value(:other_alias, :title)]
        ),
        id: "bad-alias",
        source: [name: :artifacts, path: [:artifacts]],
        item_alias: :artifact,
        key_path: [:id]
      )

    assert {:error, missing_template_errors} = Validate.element(missing_template)
    assert Enum.any?(missing_template_errors, &(&1.code == :missing_collection_template))

    assert {:error, duplicate_key_errors} = Validate.element(duplicate_keys)
    assert Enum.any?(duplicate_key_errors, &(&1.code == :duplicate_collection_key))

    assert {:error, relationship_source_errors} = Validate.element(relationship_source)
    assert Enum.any?(relationship_source_errors, &(&1.code == :invalid_collection_source))

    assert {:error, alias_errors} = Validate.element(unavailable_alias)
    assert Enum.any?(alias_errors, &(&1.code == :invalid_row_scope_binding))
  end
end
