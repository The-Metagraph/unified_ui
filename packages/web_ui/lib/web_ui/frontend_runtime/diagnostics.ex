defmodule WebUi.FrontendRuntime.Diagnostics do
  @moduledoc """
  Diagnostics for Elm frontend runtime.

  Provides validation and diagnostic functions for detecting
  frontend runtime issues.
  """

  @type diagnostic :: %{
          type: atom(),
          severity: :info | :warning | :error,
          message: String.t(),
          details: map() | nil
        }

  @doc """
  Validates hydration state structure.
  """
  @spec validate_hydration_state(map()) :: :ok | {:error, diagnostic()}
  def validate_hydration_state(state) when is_map(state) do
    required_keys = [:schema, :version, :assigns, :checksum]

    missing =
      required_keys
      |> Enum.reject(&Map.has_key?(state, &1))

    if Enum.empty?(missing) do
      validate_hydration_content(state)
    else
      {:error,
       %{
         type: :missing_hydration_keys,
         severity: :error,
         message: "Hydration state is missing required keys",
         details: %{missing: missing}
       }}
    end
  end

  @doc """
  Validates outbound message from Elm.
  """
  @spec validate_outbound_message(map()) :: :ok | {:error, diagnostic()}
  def validate_outbound_message(%{type: type, payload: payload})
      when is_binary(type) and is_map(payload) do
    :ok
  end

  def validate_outbound_message(_) do
    {:error,
     %{
       type: :invalid_outbound_message,
       severity: :error,
       message: "Outbound message must have :type (string) and :payload (map)",
       details: nil
     }}
  end

  @doc """
  Validates inbound message from server.
  """
  @spec validate_inbound_message(map()) :: :ok | {:error, diagnostic()}
  def validate_inbound_message(%{type: type, data: data, checksum: checksum})
      when type in [:state_update, :event_result] and is_map(data) and is_binary(checksum) do
    :ok
  end

  def validate_inbound_message(_) do
    {:error,
     %{
       type: :invalid_inbound_message,
       severity: :error,
       message: "Inbound message must have valid :type, :data (map), and :checksum (string)",
       details: nil
     }}
  end

  @doc """
  Validates Elm asset compilation status.
  """
  @spec validate_elm_assets(String.t()) :: :ok | {:warning, diagnostic()}
  def validate_elm_assets(_assets_path) do
    # This is a placeholder - actual implementation would check file existence
    # and compilation status of Elm assets
    :ok
  end

  # Private functions

  defp validate_hydration_content(%{schema: schema, version: version, assigns: assigns, checksum: checksum}) do
    cond do
      not is_map(schema) ->
        {:error, hydration_error(:invalid_schema, "schema must be a map")}

      not is_binary(version) ->
        {:error, hydration_error(:invalid_version, "version must be a string")}

      not is_map(assigns) ->
        {:error, hydration_error(:invalid_assigns, "assigns must be a map")}

      not is_binary(checksum) ->
        {:error, hydration_error(:invalid_checksum, "checksum must be a string")}

      true ->
        :ok
    end
  end

  defp hydration_error(type, message) do
    %{
      type: type,
      severity: :error,
      message: message,
      details: nil
    }
  end
end
