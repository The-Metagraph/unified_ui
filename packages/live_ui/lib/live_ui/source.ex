defmodule LiveUi.Source do
  @moduledoc """
  Source validation and metadata for module-backed screens and raw IUR payloads.
  """

  alias LiveUi.ConfigurationError
  alias LiveUi.IUR.Dependency

  @required_callbacks [init: 1, update: 2, view: 1]

  @type kind :: :module | :iur

  @enforce_keys [:kind]
  defstruct [:kind, :module, :iur, opts: []]

  @type t :: %__MODULE__{
          kind: kind(),
          module: module() | nil,
          iur: term() | nil,
          opts: keyword()
        }

  @spec new(module(), keyword()) :: t()
  def new(source_module, opts \\ []) when is_list(opts) do
    validate_module!(source_module)
    %__MODULE__{kind: :module, module: source_module, opts: Keyword.new(opts)}
  end

  @spec new_iur(term()) :: t()
  def new_iur(iur_tree) do
    validate_iur!(iur_tree)
    %__MODULE__{kind: :iur, iur: iur_tree, opts: []}
  end

  @spec validate_module!(module()) :: :ok
  def validate_module!(source_module) do
    cond do
      not is_atom(source_module) ->
        raise ConfigurationError.new("live_ui source must be a module", %{source: source_module})

      not module_reference?(source_module) ->
        raise ConfigurationError.new(
                "live_ui source must be a module reference",
                %{source: inspect(source_module)}
              )

      not Code.ensure_loaded?(source_module) ->
        raise ConfigurationError.new(
                "live_ui source module is not available",
                %{source: inspect(source_module)}
              )

      missing_callbacks(source_module) != [] ->
        raise ConfigurationError.new("live_ui source module is missing required callbacks", %{
                source: inspect(source_module),
                missing: missing_callbacks(source_module)
              })

      true ->
        :ok
    end
  end

  @spec validate_iur!(term()) :: :ok
  def validate_iur!(iur_tree) do
    cond do
      match?(%{__struct__: _}, iur_tree) ->
        validate_protocol_element!(iur_tree)

      is_map(iur_tree) and Dependency.markers_present?(iur_tree) ->
        case Dependency.validate_markers(iur_tree) do
          :ok -> :ok
          {:error, %ConfigurationError{} = error} -> raise error
        end

      is_map(iur_tree) ->
        :ok

      true ->
        validate_protocol_element!(iur_tree)
    end
  end

  @spec label(t()) :: String.t()
  def label(%__MODULE__{kind: :module, module: source_module}), do: module_label(source_module)

  def label(%__MODULE__{kind: :iur, iur: iur_tree}) do
    cond do
      match?(%{__struct__: _}, iur_tree) ->
        iur_tree.__struct__ |> Module.split() |> List.last() |> Kernel.||("UnifiedIUR")

      is_map(iur_tree) ->
        fetch_string_value(iur_tree, ["title", "name", "kind"], "UnifiedIUR")

      true ->
        "UnifiedIUR"
    end
  end

  @spec module_reference?(module()) :: boolean()
  def module_reference?(source_module) when is_atom(source_module) do
    source_module
    |> Atom.to_string()
    |> String.starts_with?("Elixir.")
  end

  def module_reference?(_source_module), do: false

  defp missing_callbacks(source_module) do
    Enum.reject(@required_callbacks, fn {name, arity} ->
      function_exported?(source_module, name, arity)
    end)
  end

  defp validate_protocol_element!(payload) do
    cond do
      not match?(%{__struct__: _}, payload) ->
        raise ConfigurationError.new("live_ui iur source must be a map or UnifiedIUR element", %{
                source: inspect(payload)
              })

      not Code.ensure_loaded?(UnifiedIUR.Element) ->
        raise ConfigurationError.new("UnifiedIUR.Element is not available for IUR structs", %{
                source: inspect(payload.__struct__)
              })

      UnifiedIUR.Element.impl_for(payload) in [nil, UnifiedIUR.Element.Any] ->
        raise ConfigurationError.new(
                "live_ui iur source struct must implement UnifiedIUR.Element",
                %{
                  source: inspect(payload.__struct__)
                }
              )

      true ->
        :ok
    end
  end

  defp module_label(nil), do: "LiveUi"

  defp module_label(source_module) when is_atom(source_module) do
    source_module
    |> Module.split()
    |> List.last()
    |> Kernel.||("LiveUi")
  end

  defp fetch_string_value(_map, [], default), do: default

  defp fetch_string_value(map, [key | rest], default) do
    value = Map.get(map, key, Map.get(map, String.to_atom(key)))

    case value do
      value when is_binary(value) and value != "" -> value
      value when is_atom(value) and not is_nil(value) -> Atom.to_string(value)
      _other -> fetch_string_value(map, rest, default)
    end
  end
end
