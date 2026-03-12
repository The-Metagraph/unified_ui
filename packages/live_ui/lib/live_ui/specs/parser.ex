defmodule LiveUi.Specs.Parser do
  @moduledoc """
  Repo-local parser for Spec Led markdown files plus local `spec-governance` blocks.
  """

  alias LiveUi.Specs.Document

  @block_pattern ~r/```([a-z-]+)\n([\s\S]*?)```/

  @spec read_documents(String.t()) :: [Document.t()]
  def read_documents(glob \\ ".spec/specs/**/*.spec.md") when is_binary(glob) do
    glob
    |> Path.wildcard()
    |> Enum.sort()
    |> Enum.map(&parse_file/1)
  end

  @spec parse_file(String.t()) :: Document.t()
  def parse_file(path) when is_binary(path) do
    path
    |> File.read!()
    |> parse_document(path)
  end

  @spec parse_document(String.t(), String.t()) :: Document.t()
  def parse_document(source, path) when is_binary(source) and is_binary(path) do
    %Document{
      path: path,
      meta: parse_single_object_block!(source, "spec-meta", path, required: true),
      governance: parse_single_object_block!(source, "spec-governance", path),
      requirements: parse_array_block(source, "spec-requirements"),
      scenarios: parse_array_block(source, "spec-scenarios"),
      verification: parse_array_block(source, "spec-verification"),
      exceptions: parse_array_block(source, "spec-exceptions")
    }
  end

  @spec extract_blocks(String.t()) :: [%{language: String.t(), content: String.t()}]
  def extract_blocks(source) when is_binary(source) do
    Regex.scan(@block_pattern, source, capture: :all_but_first)
    |> Enum.map(fn [language, content] ->
      %{language: language, content: String.trim(content)}
    end)
  end

  defp parse_array_block(source, language) do
    source
    |> parse_json_blocks(language)
    |> List.flatten()
  end

  defp parse_single_object_block!(source, language, path, opts \\ []) do
    blocks = parse_json_blocks(source, language)

    cond do
      length(blocks) > 1 ->
        raise ArgumentError, "expected at most one #{language} block in #{path}"

      blocks == [] and Keyword.get(opts, :required, false) ->
        raise ArgumentError, "missing #{language} block in #{path}"

      blocks == [] ->
        nil

      true ->
        hd(blocks)
    end
  end

  defp parse_json_blocks(source, language) do
    extract_blocks(source)
    |> Enum.filter(&(&1.language == language))
    |> Enum.map(fn %{content: content} -> Jason.decode!(content) end)
  end
end
