defmodule UnifiedUi.GuidesExamplesCompileTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @guides_root "guides"
  @elixir_fence ~r/```elixir[^\n]*\n(.*?)\n```/ms

  @dsl_head ~r/^\s*(state|styles|signals|vbox|hbox|text|button|label|text_input|gauge|sparkline|bar_chart|line_chart|table|menu|context_menu|tabs|tree_view)\b(?!\s*=)/m

  test "elixir code examples in guides compile" do
    failures =
      @guides_root
      |> Path.join("**/*.md")
      |> Path.wildcard()
      |> Enum.sort()
      |> Enum.flat_map(&compile_guide_examples/1)

    assert failures == [], Enum.join(failures, "\n\n")
  end

  defp compile_guide_examples(guide_path) do
    guide_path
    |> File.read!()
    |> extract_elixir_blocks()
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {code, index} ->
      source = build_compilation_source(code, guide_path, index)

      case compile_source(source) do
        :ok ->
          []

        {:error, reason} ->
          [
            """
            #{guide_path} block #{index} failed to compile:
            #{reason}
            ---
            #{preview_block(code)}
            """
            |> String.trim()
          ]
      end
    end)
  end

  defp extract_elixir_blocks(markdown) do
    @elixir_fence
    |> Regex.scan(markdown, capture: :all_but_first)
    |> Enum.map(&hd/1)
    |> Enum.map(&String.trim/1)
  end

  defp build_compilation_source(code, guide_path, index) do
    fixture_module =
      Module.concat([
        UnifiedUi,
        GuideExampleFixture,
        :"M#{:erlang.phash2({guide_path, index, code})}"
      ])

    cond do
      Regex.match?(~r/^\s*defmodule\b/m, code) ->
        code

      Regex.match?(~r/^\s*@impl\b/m, code) or Regex.match?(~r/^\s*defp?\s+\w+/m, code) ->
        """
        defmodule #{inspect(fixture_module)} do
        #{indent(code, 2)}
        end
        """

      Regex.match?(@dsl_head, code) ->
        """
        defmodule #{inspect(fixture_module)} do
          @behaviour UnifiedUi.ElmArchitecture
          use UnifiedUi.Dsl

        #{indent(code, 2)}
        end
        """

      true ->
        """
        defmodule #{inspect(fixture_module)} do
          def run do
            state = %{}
            signal = %{}
            iur = nil
            _ = {state, signal, iur}

        #{indent(code, 4)}
            :ok
          end
        end
        """
    end
  end

  defp compile_source(source) do
    capture_io(:stderr, fn ->
      Code.compile_string(source)
    end)

    :ok
  rescue
    error ->
      {:error, Exception.message(error)}
  end

  defp preview_block(code) do
    code
    |> String.split("\n")
    |> Enum.take(12)
    |> Enum.join("\n")
  end

  defp indent(code, spaces) do
    prefix = String.duplicate(" ", spaces)
    String.replace(code, ~r/^/m, prefix)
  end
end
