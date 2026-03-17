defmodule UnifiedExamples.Demo.CategoryFragment do
  @moduledoc """
  Shared placeholder fragment scaffold for aggregate demo categories.
  """

  defmacro __using__(opts) do
    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)
    summary = Keyword.fetch!(opts, :summary)
    note = Keyword.fetch!(opts, :note)

    root_id = :"#{id}_category_fragment_root"
    shell_id = :"#{id}_category_fragment_shell"
    title_id = :"#{id}_category_fragment_title"
    summary_id = :"#{id}_category_fragment_summary"
    note_id = :"#{id}_category_fragment_note"

    quote bind_quoted: [
            id: id,
            title: title,
            summary: summary,
            note: note,
            root_id: root_id,
            shell_id: shell_id,
            title_id: title_id,
            summary_id: summary_id,
            note_id: note_id
          ] do
      use UnifiedUi.Dsl

      import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

      alias UnifiedExamples.Shared.Template

      @default_theme_id Template.default_theme_id()
      @shared_style_profile Template.default_style_profile()
      @category_metadata %{
        id: id,
        title: title,
        summary: summary,
        note: note,
        root_id: root_id
      }

      @spec category_metadata() :: map()
      def category_metadata, do: @category_metadata

      @spec default_theme_id() :: atom()
      def default_theme_id, do: @default_theme_id

      @spec shared_style_profile() :: map()
      def shared_style_profile, do: @shared_style_profile

      identity do
        id(id)
        title(title)
        description(summary)
        authored_ref([:examples, :demo, :categories, id])
        tags([:example, :demo, :category_fragment, id])
      end

      shared_theme_definition()

      composition do
        root(root_id)
        mode(:fragment)
        default_slot(:default)
        summary(summary)

        box shell_id do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text title_id do
            value(title)
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text summary_id do
            value(summary)
            theme_ref(@default_theme_id)
            style_refs([:example_summary])
            tone(:muted)
            variant(:body)
          end

          text note_id do
            value(note)
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end
    end
  end
end
