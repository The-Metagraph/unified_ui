defmodule UnifiedUi.ThemeSignalValidationTest do
  use ExUnit.Case, async: true

  test "rejects default_theme values that do not reference a declared theme" do
    assert_compile_dsl_error(
      """
      identity do
        id(:missing_theme_screen)
      end

      composition do
        root(:missing_theme_root)
      end

      themes do
        default_theme(:workspace)

        theme do
          id(:fallback)

          palette_color do
            id(:surface)
            color(named_color(:black))
          end
        end
      end
      """,
      "themes.default_theme must reference a declared theme id"
    )
  end

  test "rejects invalid style references and unsupported state variants" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_style_screen)
      end

      composition do
        root(:invalid_style_root)

        button :primary do
          label("Primary")
          theme_ref(:workspace)
          style_refs([:missing_component])

          style(
            style_value(
              state_variants: %{
                hovered: style_value(border_color: named_color(:cyan))
              }
            )
          )
        end
      end

      themes do
        default_theme(:workspace)

        theme do
          id(:workspace)

          palette_color do
            id(:surface)
            color(named_color(:black))
          end
        end
      end
      """,
      "style_refs must reference declared component styles"
    )
  end

  test "rejects invalid style opacity values" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_opacity_screen)
      end

      composition do
        root(:invalid_opacity_root)

        box :shell do
          style(
            style_value(
              visibility: %{opacity: 2}
            )
          )
        end
      end
      """,
      "visibility.opacity must be between 0.0 and 1.0"
    )
  end

  test "rejects empty binding paths and renderer-local signal keys" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_signal_screen)
      end

      composition do
        root(:invalid_signal_root)
      end

      signals do
        data_binding do
          id(:bad_binding)
          path([])
        end
      end
      """,
      "binding path must not be empty"
    )

    assert_compile_dsl_error(
      """
      identity do
        id(:renderer_local_signal_screen)
      end

      composition do
        root(:renderer_local_signal_root)
      end

      signals do
        interaction do
          id(:bad_interaction)
          family(:click)
          intent(:save_profile)
          source_context(phx_click: \"save\")
        end
      end
      """,
      "renderer-local key :phx_click is not allowed"
    )
  end

  test "rejects unknown binding refs in interactions and node signal refs" do
    assert_compile_dsl_error(
      """
      identity do
        id(:unknown_binding_ref_screen)
      end

      composition do
        root(:unknown_binding_ref_root)

        button :save_button do
          label("Save")
          interaction_refs([:save_profile])
        end
      end

      signals do
        interaction do
          id(:save_profile)
          family(:submit)
          intent(:save_profile)
          payload_mapping(profile: binding_ref(:missing_binding))
        end
      end
      """,
      "payload mapping references unknown binding"
    )

    assert_compile_dsl_error(
      """
      identity do
        id(:unknown_interaction_ref_screen)
      end

      composition do
        root(:unknown_interaction_ref_root)

        button :save_button do
          label("Save")
          interaction_refs([:missing_interaction])
        end
      end
      """,
      "interaction_refs must reference declared interactions"
    )
  end

  defp compile_module(body) do
    module_name = "Generated#{System.unique_integer([:positive])}"

    Code.compile_string("""
    defmodule UnifiedUi.ThemeSignalValidationTest.#{module_name} do
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
