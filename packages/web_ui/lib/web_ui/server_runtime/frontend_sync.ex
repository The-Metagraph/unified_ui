defmodule WebUi.ServerRuntime.FrontendSync do
  @moduledoc """
  Frontend synchronization state for hydrating the Elm runtime.

  This module manages the data contract between the Phoenix server
  and the Elm frontend. It ensures that the frontend receives a
  consistent, validated initial state.
  """

  alias WebUi.ServerRuntime.Error

  @enforce_keys [:schema, :version]
  defstruct [:schema, :version, :checksum]

  @type t :: %__MODULE__{
          schema: map(),
          version: String.t(),
          checksum: String.t() | nil
        }

  @doc """
  Builds a frontend sync structure from the screen schema and assigns.
  """
  @spec build(module(), map()) :: {:ok, t()} | {:error, Error.t()}
  def build(screen, assigns) do
    with {:ok, schema} <- validate_schema(screen.frontend_schema()),
         :ok <- validate_assigns_against_schema(schema, assigns) do
      {:ok,
       %__MODULE__{
         schema: schema,
         version: version_for(screen),
         checksum: checksum_for(assigns)
       }}
    end
  end

  @doc """
  Converts the sync state to a map for Elm hydration.
  """
  @spec to_map(t(), map()) :: map()
  def to_map(%__MODULE__{} = sync, assigns) do
    %{
      schema: sync.schema,
      version: sync.version,
      assigns: filter_by_schema(assigns, sync.schema),
      checksum: sync.checksum
    }
  end

  @doc """
  Updates the sync after state changes.
  """
  @spec update(t(), map()) :: t()
  def update(%__MODULE__{} = sync, new_assigns) do
    %{sync | checksum: checksum_for(new_assigns)}
  end

  @doc """
  Validates that incoming frontend state matches expected sync state.
  """
  @spec validate_sync(t(), map()) :: :ok | {:error, Error.t()}
  def validate_sync(%__MODULE__{checksum: expected_checksum}, frontend_state) do
    case Map.get(frontend_state, :checksum) do
      nil ->
        {:error, Error.hydration_failed(nil, :missing_checksum)}

      ^expected_checksum ->
        :ok

      other ->
        {:error, Error.sync_mismatch(nil, :checksum, expected_checksum, other)}
    end
  end

  # Private functions

  defp validate_schema(schema) when is_map(schema) do
    required_keys = [:version, :fields]

    if Enum.all?(required_keys, &Map.has_key?(schema, &1)) do
      {:ok, schema}
    else
      {:error, Error.invalid_frontend_schema(nil)}
    end
  end

  defp validate_schema(_other), do: {:error, Error.invalid_frontend_schema(nil)}

  defp validate_assigns_against_schema(schema, assigns) do
    fields = Map.get(schema, :fields, %{})

    invalid_keys =
      assigns
      |> Map.keys()
      |> Enum.reject(fn key ->
        Map.has_key?(fields, key)
      end)

    if Enum.empty?(invalid_keys) do
      :ok
    else
      {:error, Error.hydration_failed(nil, {:invalid_keys, invalid_keys})}
    end
  end

  defp filter_by_schema(assigns, schema) do
    fields = Map.get(schema, :fields, %{})
    Map.take(assigns, Map.keys(fields))
  end

  defp version_for(screen) do
    case function_exported?(screen, :frontend_version, 0) do
      true -> screen.frontend_version()
      false -> "0.1.0"
    end
  end

  defp checksum_for(assigns) do
    :crypto.hash(:md5, :erlang.term_to_binary(assigns))
    |> Base.encode16(case: :lower)
  end
end
