defmodule UnifiedExamples.Shared.Template do
  @moduledoc """
  Shared `UnifiedUi` DSL template for the standalone example-app suite.
  """

  @default_theme_id :example_suite_default
  @default_notes """
  This example uses the shared suite template, theme, and style profile.
  """

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec default_notes() :: String.t()
  def default_notes, do: String.trim(@default_notes)

  @spec default_style_profile() :: map()
  def default_style_profile do
    %{
      shell: [:example_shell],
      panel: [:example_panel],
      form_shell: [:example_form_shell],
      title: [:example_title],
      summary: [:example_summary],
      notes: [:example_notes],
      interaction_button: [:example_primary_button],
      button: [:example_primary_button],
      text_input: [:example_primary_input]
    }
  end

  defmacro shared_theme_definition do
    quote do
      themes do
        default_theme(unquote(@default_theme_id))

        theme do
          id(unquote(@default_theme_id))
          summary("Shared default theme for the standalone example-app suite")

          palette_color do
            id(:surface)
            color(rgb_color(18, 18, 18))
          end

          palette_color do
            id(:accent)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:success)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:warning)
            color(rgb_color(255, 184, 0))
          end

          palette_color do
            id(:critical)
            color(rgb_color(235, 123, 123))
          end

          palette_color do
            id(:muted)
            color(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:surface)
            value(rgb_color(18, 18, 18))
          end

          semantic_role do
            id(:accent)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:success)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:warning)
            value(rgb_color(255, 184, 0))
          end

          semantic_role do
            id(:critical)
            value(rgb_color(235, 123, 123))
          end

          semantic_role do
            id(:muted)
            value(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:foreground)
            value(rgb_color(232, 232, 232))
          end

          token do
            id(:shell_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                spacing: %{padding: 2, gap: 1},
                border: %{width: 1, style: :solid}
              )
            )
          end

          token do
            id(:panel_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                spacing: %{padding: 2, gap: 1},
                border: %{width: 1, style: :solid}
              )
            )
          end

          token do
            id(:accent_action)

            value(
              style_value(
                background: role_ref(:accent),
                foreground: rgb_color(10, 10, 10),
                border_color: role_ref(:accent),
                emphasis: %{tone: :accent}
              )
            )
          end

          token do
            id(:input_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                border_color: role_ref(:muted)
              )
            )
          end

          component_style do
            id(:example_shell)
            component(:box)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:shell_surface)],
                sizing: %{width: :fill},
                alignment: %{align: :stretch}
              )
            )
          end

          component_style do
            id(:example_panel)
            component(:box)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:panel_surface)],
                emphasis: %{tone: :surface}
              )
            )
          end

          component_style do
            id(:example_form_shell)
            component(:form_builder)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:panel_surface)],
                emphasis: %{tone: :surface}
              )
            )
          end

          component_style do
            id(:example_title)
            component(:text)
            variant(:headline)

            style(
              style_value(
                foreground: role_ref(:accent),
                emphasis: %{weight: :strong}
              )
            )
          end

          component_style do
            id(:example_summary)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_notes)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_primary_button)
            component(:button)
            variant(:solid)

            style(style_value(token_refs: [token_ref(:accent_action)]))
          end

          component_style do
            id(:example_primary_input)
            component(:text_input)
            variant(:filled)

            style(style_value(token_refs: [token_ref(:input_surface)]))
          end
        end
      end
    end
  end

  def interaction_demo(opts) when is_list(opts) do
    widget = Keyword.fetch!(opts, :widget)

    UnifiedExamples.Shared.InteractionDemo.normalize(
      Keyword.get(opts, :interaction_demo),
      %{
        directory: Atom.to_string(Keyword.fetch!(opts, :id)),
        widget: widget,
        family: UnifiedExamples.Shared.InteractionDemo.family_for_widget(widget)
      }
    )
  end

  defmacro __using__(opts) do
    opts =
      case Keyword.fetch(opts, :interaction_demo) do
        {:ok, interaction_demo} ->
          if Macro.quoted_literal?(interaction_demo) do
            {evaluated, _binding} = Code.eval_quoted(interaction_demo, [], __CALLER__)
            Keyword.put(opts, :interaction_demo, evaluated)
          else
            opts
          end

        _other ->
          opts
      end

    opts = Keyword.put_new(opts, :notes, default_notes())
    Module.put_attribute(__CALLER__.module, :example_template_opts, opts)

    quote do
      use UnifiedUi.Dsl

      import UnifiedExamples.Shared.Template, only: [example_form_panel: 1, example_panel: 1]
    end
  end

  defmacro example_panel(do: demo_ast) do
    opts =
      __CALLER__.module
      |> Module.get_attribute(:example_template_opts)
      |> Kernel.||(
        raise ArgumentError,
              "example_panel/1 requires `use UnifiedExamples.Shared.Template` first"
      )

    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)
    summary = Keyword.fetch!(opts, :summary)
    widget = Keyword.fetch!(opts, :widget)
    notes = Keyword.get(opts, :notes, default_notes())
    interaction_demo = interaction_demo(opts)

    root_id = String.to_atom("#{id}_root")
    shell_id = String.to_atom("#{id}_shell")
    title_id = String.to_atom("#{id}_title")
    summary_id = String.to_atom("#{id}_summary")
    panel_id = String.to_atom("#{id}_panel")
    notes_text_id = String.to_atom("#{id}_notes_text")
    interaction_button_id = String.to_atom("#{id}_interaction_trigger")
    interaction_id = String.to_atom("#{id}_interaction")

    notes_block =
      if notes in [nil, ""] do
        quote(do: nil)
      else
        quote do
          text unquote(notes_text_id) do
            value(unquote(notes))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end

    interaction_block =
      case interaction_demo.mode do
        :shared_trigger ->
          quote do
            signals do
              namespace(:examples)

              interaction do
                id(unquote(interaction_id))
                family(unquote(interaction_demo.family))
                intent(unquote(String.to_atom("inspect_#{widget}")))

                source_context(
                  element_id: unquote(interaction_button_id),
                  scope: :screen
                )

                target_intent(action: :review_example)

                payload_mapping(
                  widget: unquote(widget),
                  example: unquote(widget),
                  outcome: unquote(interaction_demo.outcome),
                  source: :shared_example_trigger
                )

                summary(unquote(interaction_demo.idle_prompt))
              end
            end
          end

        _other ->
          quote(do: nil)
      end

    interaction_button_block =
      case interaction_demo.mode do
        :shared_trigger ->
          quote do
            button unquote(interaction_button_id) do
              label(unquote(interaction_demo.trigger_label))
              interaction_refs([unquote(interaction_id)])
              theme_ref(unquote(@default_theme_id))
              style_refs([:example_primary_button])
              tone(:accent)
              variant(:solid)
            end
          end

        _other ->
          quote(do: nil)
      end

    quote do
      @example_metadata %{
        id: unquote(id),
        root_id: unquote(root_id),
        title: unquote(title),
        summary: unquote(summary),
        notes: unquote(notes),
        widget: unquote(widget),
        theme_id: unquote(@default_theme_id),
        interaction_demo: unquote(Macro.escape(interaction_demo))
      }

      def example_metadata, do: @example_metadata
      def example_interaction_demo, do: @example_metadata.interaction_demo

      def default_theme_id, do: unquote(@default_theme_id)

      def shared_style_profile, do: UnifiedExamples.Shared.Template.default_style_profile()

      identity do
        id(unquote(id))
        title(unquote(title))
        description(unquote(summary))
        authored_ref([:examples, unquote(id)])
        tags([:example, unquote(widget)])
      end

      unquote(interaction_block)

      themes do
        default_theme(unquote(@default_theme_id))

        theme do
          id(unquote(@default_theme_id))
          summary("Shared default theme for the standalone example-app suite")

          palette_color do
            id(:surface)
            color(rgb_color(18, 18, 18))
          end

          palette_color do
            id(:accent)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:success)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:warning)
            color(rgb_color(255, 184, 0))
          end

          palette_color do
            id(:critical)
            color(rgb_color(235, 123, 123))
          end

          palette_color do
            id(:muted)
            color(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:surface)
            value(rgb_color(18, 18, 18))
          end

          semantic_role do
            id(:accent)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:success)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:warning)
            value(rgb_color(255, 184, 0))
          end

          semantic_role do
            id(:critical)
            value(rgb_color(235, 123, 123))
          end

          semantic_role do
            id(:muted)
            value(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:foreground)
            value(rgb_color(232, 232, 232))
          end

          token do
            id(:shell_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                spacing: %{padding: 2, gap: 1},
                border: %{width: 1, style: :solid}
              )
            )
          end

          token do
            id(:panel_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                spacing: %{padding: 2, gap: 1},
                border: %{width: 1, style: :solid}
              )
            )
          end

          token do
            id(:accent_action)

            value(
              style_value(
                background: role_ref(:accent),
                foreground: rgb_color(10, 10, 10),
                border_color: role_ref(:accent),
                emphasis: %{tone: :accent}
              )
            )
          end

          token do
            id(:input_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                border_color: role_ref(:muted)
              )
            )
          end

          component_style do
            id(:example_shell)
            component(:box)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:shell_surface)],
                sizing: %{width: :fill},
                alignment: %{align: :stretch}
              )
            )
          end

          component_style do
            id(:example_panel)
            component(:box)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:panel_surface)],
                emphasis: %{tone: :surface}
              )
            )
          end

          component_style do
            id(:example_form_shell)
            component(:form_builder)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:panel_surface)],
                emphasis: %{tone: :surface}
              )
            )
          end

          component_style do
            id(:example_title)
            component(:text)
            variant(:headline)

            style(
              style_value(
                foreground: role_ref(:accent),
                emphasis: %{weight: :strong}
              )
            )
          end

          component_style do
            id(:example_summary)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_notes)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_primary_button)
            component(:button)
            variant(:solid)

            style(style_value(token_refs: [token_ref(:accent_action)]))
          end

          component_style do
            id(:example_primary_input)
            component(:text_input)
            variant(:filled)

            style(style_value(token_refs: [token_ref(:input_surface)]))
          end
        end
      end

      composition do
        root(unquote(root_id))
        mode(:screen)
        summary("Shared example-app shell")

        box unquote(shell_id) do
          theme_ref(unquote(@default_theme_id))
          style_refs([:example_shell])
          tone(:surface)
          variant(:panel)

          text unquote(title_id) do
            value(unquote(title))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text unquote(summary_id) do
            value(unquote(summary))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_summary])
            tone(:muted)
            variant(:body)
          end

          box unquote(panel_id) do
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_panel])
            tone(:surface)
            variant(:panel)

            unquote(demo_ast)
          end

          unquote(interaction_button_block)

          unquote(notes_block)
        end
      end
    end
  end

  defmacro example_form_panel(do: demo_ast) do
    opts =
      __CALLER__.module
      |> Module.get_attribute(:example_template_opts)
      |> Kernel.||(
        raise ArgumentError,
              "example_form_panel/1 requires `use UnifiedExamples.Shared.Template` first"
      )

    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)
    summary = Keyword.fetch!(opts, :summary)
    widget = Keyword.fetch!(opts, :widget)
    notes = Keyword.get(opts, :notes, default_notes())
    interaction_demo = interaction_demo(opts)

    root_id = String.to_atom("#{id}_root")
    shell_id = String.to_atom("#{id}_shell")
    title_id = String.to_atom("#{id}_title")
    summary_id = String.to_atom("#{id}_summary")
    spacer_id = String.to_atom("#{id}_form_gap")
    notes_text_id = String.to_atom("#{id}_notes_text")
    interaction_button_id = String.to_atom("#{id}_interaction_trigger")
    interaction_id = String.to_atom("#{id}_interaction")

    notes_block =
      if notes in [nil, ""] do
        quote(do: nil)
      else
        quote do
          text unquote(notes_text_id) do
            value(unquote(notes))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end

    interaction_block =
      case interaction_demo.mode do
        :shared_trigger ->
          quote do
            signals do
              namespace(:examples)

              interaction do
                id(unquote(interaction_id))
                family(unquote(interaction_demo.family))
                intent(unquote(String.to_atom("inspect_#{widget}")))

                source_context(
                  element_id: unquote(interaction_button_id),
                  scope: :screen
                )

                target_intent(action: :review_example)

                payload_mapping(
                  widget: unquote(widget),
                  example: unquote(widget),
                  outcome: unquote(interaction_demo.outcome),
                  source: :shared_example_trigger
                )

                summary(unquote(interaction_demo.idle_prompt))
              end
            end
          end

        :form_shell ->
          quote do
            signals do
              namespace(:examples)

              interaction do
                id(unquote(interaction_id))
                family(unquote(interaction_demo.family))
                intent(unquote(String.to_atom("inspect_#{widget}")))

                source_context(
                  element_id: unquote(shell_id),
                  scope: :screen
                )

                target_intent(action: :review_example)

                payload_mapping(
                  widget: unquote(widget),
                  example: unquote(widget),
                  outcome: unquote(interaction_demo.outcome),
                  source: :shared_form_shell
                )

                summary(unquote(interaction_demo.idle_prompt))
              end
            end
          end

        _other ->
          quote(do: nil)
      end

    interaction_button_block =
      case interaction_demo.mode do
        :shared_trigger ->
          quote do
            button unquote(interaction_button_id) do
              label(unquote(interaction_demo.trigger_label))
              interaction_refs([unquote(interaction_id)])
              theme_ref(unquote(@default_theme_id))
              style_refs([:example_primary_button])
              tone(:accent)
              variant(:solid)
            end
          end

        _other ->
          quote(do: nil)
      end

    shell_interaction_block =
      case interaction_demo.mode do
        :form_shell ->
          quote do
            interaction_refs([unquote(interaction_id)])
          end

        _other ->
          quote(do: nil)
      end

    quote do
      @example_metadata %{
        id: unquote(id),
        root_id: unquote(root_id),
        title: unquote(title),
        summary: unquote(summary),
        notes: unquote(notes),
        widget: unquote(widget),
        theme_id: unquote(@default_theme_id),
        interaction_demo: unquote(Macro.escape(interaction_demo))
      }

      def example_metadata, do: @example_metadata
      def example_interaction_demo, do: @example_metadata.interaction_demo

      def default_theme_id, do: unquote(@default_theme_id)

      def shared_style_profile, do: UnifiedExamples.Shared.Template.default_style_profile()

      identity do
        id(unquote(id))
        title(unquote(title))
        description(unquote(summary))
        authored_ref([:examples, unquote(id)])
        tags([:example, unquote(widget)])
      end

      unquote(interaction_block)

      themes do
        default_theme(unquote(@default_theme_id))

        theme do
          id(unquote(@default_theme_id))
          summary("Shared default theme for the standalone example-app suite")

          palette_color do
            id(:surface)
            color(rgb_color(18, 18, 18))
          end

          palette_color do
            id(:accent)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:success)
            color(rgb_color(0, 255, 136))
          end

          palette_color do
            id(:warning)
            color(rgb_color(255, 184, 0))
          end

          palette_color do
            id(:critical)
            color(rgb_color(235, 123, 123))
          end

          palette_color do
            id(:muted)
            color(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:surface)
            value(rgb_color(18, 18, 18))
          end

          semantic_role do
            id(:accent)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:success)
            value(rgb_color(0, 255, 136))
          end

          semantic_role do
            id(:warning)
            value(rgb_color(255, 184, 0))
          end

          semantic_role do
            id(:critical)
            value(rgb_color(235, 123, 123))
          end

          semantic_role do
            id(:muted)
            value(rgb_color(102, 102, 102))
          end

          semantic_role do
            id(:foreground)
            value(rgb_color(232, 232, 232))
          end

          token do
            id(:panel_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                spacing: %{padding: 2, gap: 1},
                border: %{width: 1, style: :solid}
              )
            )
          end

          token do
            id(:accent_action)

            value(
              style_value(
                background: role_ref(:accent),
                foreground: rgb_color(10, 10, 10),
                border_color: role_ref(:accent),
                emphasis: %{tone: :accent}
              )
            )
          end

          token do
            id(:input_surface)

            value(
              style_value(
                background: token_ref(:surface),
                foreground: role_ref(:foreground),
                border_color: role_ref(:muted)
              )
            )
          end

          component_style do
            id(:example_form_shell)
            component(:form_builder)
            variant(:panel)

            style(
              style_value(
                token_refs: [token_ref(:panel_surface)],
                emphasis: %{tone: :surface}
              )
            )
          end

          component_style do
            id(:example_title)
            component(:text)
            variant(:headline)

            style(
              style_value(
                foreground: role_ref(:accent),
                emphasis: %{weight: :strong}
              )
            )
          end

          component_style do
            id(:example_summary)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_notes)
            component(:text)
            variant(:body)

            style(style_value(foreground: role_ref(:muted)))
          end

          component_style do
            id(:example_primary_button)
            component(:button)
            variant(:solid)

            style(style_value(token_refs: [token_ref(:accent_action)]))
          end

          component_style do
            id(:example_primary_input)
            component(:text_input)
            variant(:filled)

            style(style_value(token_refs: [token_ref(:input_surface)]))
          end
        end
      end

      composition do
        root(unquote(root_id))
        mode(:screen)
        summary("Shared form-oriented example-app shell")

        form_builder unquote(shell_id) do
          summary("Shared form-oriented example-app shell")
          theme_ref(unquote(@default_theme_id))
          style_refs([:example_form_shell])
          tone(:surface)
          variant(:panel)
          unquote(shell_interaction_block)

          text unquote(title_id) do
            value(unquote(title))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text unquote(summary_id) do
            value(unquote(summary))
            theme_ref(unquote(@default_theme_id))
            style_refs([:example_summary])
            tone(:muted)
            variant(:body)
          end

          spacer unquote(spacer_id) do
            size(:sm)
          end

          unquote(demo_ast)

          unquote(interaction_button_block)

          unquote(notes_block)
        end
      end
    end
  end
end
