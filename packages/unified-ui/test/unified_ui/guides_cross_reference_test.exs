defmodule UnifiedUi.GuidesCrossReferenceTest do
  use ExUnit.Case, async: true

  @guides_root "guides"

  test "guide markdown cross references resolve to existing files/anchors" do
    guide_files = Path.wildcard(Path.join(@guides_root, "**/*.md"))

    failures =
      Enum.flat_map(guide_files, fn guide_path ->
        guide_path
        |> File.read!()
        |> markdown_links()
        |> Enum.flat_map(fn %{target: target} -> validate_link(guide_path, target) end)
      end)

    assert failures == [], Enum.join(failures, "\n")
  end

  defp markdown_links(markdown) do
    Regex.scan(~r/!?\[[^\]]+\]\(([^)]+)\)/, markdown)
    |> Enum.map(fn [full_match, raw_target] ->
      %{full: full_match, target: parse_target(raw_target)}
    end)
    |> Enum.reject(fn %{full: full_match, target: target} ->
      String.starts_with?(full_match, "![") or
        target == "" or
        String.starts_with?(target, "http://") or
        String.starts_with?(target, "https://") or
        String.starts_with?(target, "mailto:") or
        String.starts_with?(target, "tel:")
    end)
  end

  defp parse_target(raw_target) do
    trimmed = String.trim(raw_target)

    if String.starts_with?(trimmed, "<") and String.contains?(trimmed, ">") do
      trimmed
      |> String.trim_leading("<")
      |> String.split(">", parts: 2)
      |> hd()
      |> String.trim()
    else
      trimmed
      |> String.split(~r/\s+/, parts: 2)
      |> hd()
    end
  end

  defp validate_link(guide_path, "#" <> fragment) do
    validate_fragment(guide_path, fragment, guide_path)
  end

  defp validate_link(guide_path, target) do
    {target_path, fragment} = split_fragment(target)

    absolute_target =
      guide_path
      |> Path.dirname()
      |> Path.join(target_path)
      |> Path.expand()

    cond do
      not File.exists?(absolute_target) ->
        [
          "Broken guide link in #{guide_path}: #{target} (resolved path does not exist: #{absolute_target})"
        ]

      fragment == nil ->
        []

      true ->
        validate_fragment(absolute_target, fragment, guide_path)
    end
  end

  defp split_fragment(target) do
    case String.split(target, "#", parts: 2) do
      [path] -> {path, nil}
      [path, fragment] -> {path, fragment}
    end
  end

  defp validate_fragment(target_file, fragment, guide_path) do
    normalized_fragment = normalize_heading(fragment)

    headings =
      target_file
      |> File.read!()
      |> extract_headings()

    if normalized_fragment in headings do
      []
    else
      [
        "Broken guide anchor in #{guide_path}: ##{fragment} (not found in #{target_file})"
      ]
    end
  end

  defp extract_headings(markdown) do
    markdown
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.starts_with?(&1, "#"))
    |> Enum.map(fn line ->
      line
      |> String.trim_leading("#")
      |> String.trim()
      |> normalize_heading()
    end)
    |> MapSet.new()
  end

  defp normalize_heading(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\p{L}\p{N}\s-]/u, "")
    |> String.trim()
    |> String.replace(~r/\s+/, "-")
    |> String.replace(~r/-+/, "-")
  end
end
