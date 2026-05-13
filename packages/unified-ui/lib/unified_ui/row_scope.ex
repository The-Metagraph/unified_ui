defmodule UnifiedUi.RowScope do
  @moduledoc """
  Portable row-scope references for repeated collection authoring.
  """

  @type path_segment :: atom() | String.t()
  @type value_ref :: %{
          required(:kind) => :row_value,
          required(:path) => [path_segment()],
          optional(:alias) => atom()
        }
  @type index_ref :: %{
          required(:kind) => :row_index,
          optional(:alias) => atom()
        }
  @type key_ref :: %{
          required(:kind) => :row_key,
          required(:path) => [path_segment()],
          optional(:alias) => atom()
        }
  @type payload_ref :: %{
          required(:kind) => :row_payload,
          required(:path) => [path_segment()],
          optional(:alias) => atom()
        }
  @type ref_t :: value_ref() | index_ref() | key_ref() | payload_ref()

  @spec value(path_segment() | [path_segment()], keyword()) :: value_ref()
  def value(path, opts \\ []) do
    :row_value
    |> path_ref(path)
    |> maybe_put_alias(opts)
  end

  @spec index(keyword()) :: index_ref()
  def index(opts \\ []) do
    %{kind: :row_index}
    |> maybe_put_alias(opts)
  end

  @spec key(path_segment() | [path_segment()], keyword()) :: key_ref()
  def key(path, opts \\ []) do
    :row_key
    |> path_ref(path)
    |> maybe_put_alias(opts)
  end

  @spec payload(path_segment() | [path_segment()], keyword()) :: payload_ref()
  def payload(path, opts \\ []) do
    :row_payload
    |> path_ref(path)
    |> maybe_put_alias(opts)
  end

  @spec reference?(term()) :: boolean()
  def reference?(%{kind: kind}) when kind in [:row_value, :row_index, :row_key, :row_payload],
    do: true

  def reference?(%{"kind" => kind})
      when kind in [:row_value, :row_index, :row_key, :row_payload],
      do: true

  def reference?(_other), do: false

  defp path_ref(kind, path) when is_atom(path) or is_binary(path), do: %{kind: kind, path: [path]}
  defp path_ref(kind, path) when is_list(path), do: %{kind: kind, path: path}

  defp maybe_put_alias(ref, opts) do
    case Keyword.get(opts, :alias) do
      nil -> ref
      alias_name when is_atom(alias_name) -> Map.put(ref, :alias, alias_name)
    end
  end
end
