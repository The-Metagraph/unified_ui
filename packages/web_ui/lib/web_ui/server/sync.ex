defmodule WebUi.Server.Sync do
  @moduledoc """
  Placeholder sync-envelope helpers between the authoritative server runtime and
  the frontend runtime.
  """

  alias WebUi.Server.Error

  @type kind :: :hydrate | :update

  @spec supported_kinds() :: [kind()]
  def supported_kinds do
    [:hydrate, :update]
  end

  @spec outbound(map(), keyword()) :: {:ok, map()}
  def outbound(view_state, opts \\ []) when is_map(view_state) do
    {:ok,
     %{
       kind: Keyword.get(opts, :kind, :hydrate),
       revision: Map.get(view_state, :revision, 0),
       payload: view_state
     }}
  end

  @spec inbound(map()) :: {:ok, map()} | {:error, Error.t()}
  def inbound(%{kind: kind, revision: revision, payload: payload})
      when kind in [:hydrate, :update] and is_integer(revision) and is_map(payload) do
    {:ok, %{kind: kind, revision: revision, payload: payload}}
  end

  def inbound(%{"kind" => kind, "revision" => revision, "payload" => payload})
      when kind in [:hydrate, :update] and is_integer(revision) and is_map(payload) do
    {:ok, %{kind: kind, revision: revision, payload: payload}}
  end

  def inbound(other), do: {:error, Error.invalid_sync_envelope(other)}
end
