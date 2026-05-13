defmodule UnifiedIUR.Binding do
  @moduledoc """
  Canonical binding and dependency references for `UnifiedIUR`.
  """

  @type path_segment :: atom() | String.t()
  @type t :: %__MODULE__{
          name: atom() | String.t() | nil,
          path: [path_segment()],
          scope: [path_segment()],
          value: term(),
          default: term(),
          format: atom() | String.t() | nil,
          source: atom() | String.t() | nil,
          collection?: boolean(),
          depends_on: [dependency_reference()],
          derived: map(),
          metadata: map()
        }

  @type dependency_reference :: %{
          optional(:scope) => [path_segment()],
          optional(:format) => atom() | String.t(),
          optional(:source) => atom() | String.t(),
          path: [path_segment()]
        }
  @type row_scope_target ::
          :content
          | :style_variant
          | :visibility
          | :interaction_payload
          | :selection_state
          | atom()
          | String.t()

  defstruct name: nil,
            path: [],
            scope: [],
            value: nil,
            default: nil,
            format: nil,
            source: nil,
            collection?: false,
            depends_on: [],
            derived: %{},
            metadata: %{}

  @spec new(keyword() | map() | t() | nil) :: t()
  def new(nil), do: %__MODULE__{}
  def new(%__MODULE__{} = binding), do: normalize(binding)
  def new(binding) when is_list(binding), do: binding |> Enum.into(%{}) |> new()
  def new(binding) when is_map(binding), do: binding |> struct_from_map() |> normalize()

  @spec row_scope(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) ::
          t()
  def row_scope(row_alias, path, opts \\ []) when is_atom(row_alias) or is_binary(row_alias) do
    opts = normalize_map(opts)
    target = fetch(opts, :target, :content)
    binding_kind = fetch(opts, :binding_kind, target)

    new(%{
      name: fetch(opts, :name, row_alias),
      path: path,
      scope: [row_alias],
      format: fetch(opts, :format),
      source: :row_scope,
      default: fetch(opts, :default),
      metadata:
        %{}
        |> maybe_put(:row_alias, row_alias)
        |> maybe_put(:target, target)
        |> maybe_put(:binding_kind, binding_kind)
    })
  end

  @spec row_value(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) ::
          t()
  def row_value(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :content)
    |> Map.put(:binding_kind, :value)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec row_style_variant(
          atom() | String.t(),
          [path_segment()] | path_segment(),
          keyword() | map()
        ) :: t()
  def row_style_variant(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :style_variant)
    |> Map.put(:binding_kind, :style_variant)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec row_visibility(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) ::
          t()
  def row_visibility(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :visibility)
    |> Map.put(:binding_kind, :visibility)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec row_payload(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) ::
          t()
  def row_payload(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :interaction_payload)
    |> Map.put(:binding_kind, :payload)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec row_selection(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) ::
          t()
  def row_selection(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :selection_state)
    |> Map.put(:binding_kind, :selection)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec row_index(atom() | String.t(), keyword() | map()) :: t()
  def row_index(index_alias, opts \\ []) when is_atom(index_alias) or is_binary(index_alias) do
    opts
    |> normalize_map()
    |> Map.put(:name, index_alias)
    |> Map.put(:target, :content)
    |> Map.put(:binding_kind, :index)
    |> then(&row_scope(index_alias, [], &1))
  end

  @spec row_key(atom() | String.t(), [path_segment()] | path_segment(), keyword() | map()) :: t()
  def row_key(row_alias, path, opts \\ []) do
    opts
    |> normalize_map()
    |> Map.put(:target, :selection_state)
    |> Map.put(:binding_kind, :key)
    |> then(&row_scope(row_alias, path, &1))
  end

  @spec reference([path_segment()] | path_segment(), keyword() | map()) ::
          dependency_reference()
  def reference(path, opts \\ []) do
    opts = normalize_map(opts)

    %{}
    |> Map.put(:path, normalize_path(path))
    |> maybe_put(:scope, normalize_optional_path(fetch(opts, :scope)))
    |> maybe_put(:format, fetch(opts, :format))
    |> maybe_put(:source, fetch(opts, :source))
  end

  @spec put_dependency(
          t() | keyword() | map() | nil,
          dependency_reference() | [path_segment()] | path_segment(),
          keyword() | map()
        ) :: t()
  def put_dependency(binding, dependency, opts \\ []) do
    binding = new(binding)

    reference =
      case dependency do
        %{path: _path} = reference -> normalize_reference(reference)
        %{"path" => _path} = reference -> normalize_reference(reference)
        path -> reference(path, opts)
      end

    %{binding | depends_on: binding.depends_on ++ [reference]}
  end

  @spec put_derived(t() | keyword() | map() | nil, atom() | String.t(), term()) :: t()
  def put_derived(binding, key, value) do
    binding = new(binding)
    %{binding | derived: Map.put(binding.derived, key, value)}
  end

  defp struct_from_map(binding) do
    %__MODULE__{
      name: fetch(binding, :name),
      path: normalize_path(fetch(binding, :path, [])),
      scope: normalize_path(fetch(binding, :scope, [])),
      value: fetch(binding, :value),
      default: fetch(binding, :default),
      format: fetch(binding, :format),
      source: fetch(binding, :source),
      collection?: fetch(binding, :collection?, false),
      depends_on: fetch(binding, :depends_on, []),
      derived: normalize_map(fetch(binding, :derived, %{})),
      metadata: normalize_map(fetch(binding, :metadata, %{}))
    }
  end

  defp normalize(%__MODULE__{} = binding) do
    %__MODULE__{
      name: binding.name,
      path: normalize_path(binding.path),
      scope: normalize_path(binding.scope),
      value: binding.value,
      default: binding.default,
      format: binding.format,
      source: binding.source,
      collection?: binding.collection? || false,
      depends_on: Enum.map(binding.depends_on, &normalize_reference/1),
      derived: normalize_map(binding.derived),
      metadata: normalize_map(binding.metadata)
    }
  end

  defp normalize_reference(reference) do
    %{
      path:
        reference
        |> fetch(:path, [])
        |> normalize_path()
    }
    |> maybe_put(:scope, normalize_optional_path(fetch(reference, :scope)))
    |> maybe_put(:format, fetch(reference, :format))
    |> maybe_put(:source, fetch(reference, :source))
  end

  defp normalize_optional_path(nil), do: nil
  defp normalize_optional_path(path), do: normalize_path(path)

  defp normalize_path(nil), do: []
  defp normalize_path(path) when is_atom(path) or is_binary(path), do: [path]
  defp normalize_path(path) when is_list(path), do: path

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp fetch(source, key, default \\ nil) do
    Map.get(source, key, Map.get(source, Atom.to_string(key), default))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
