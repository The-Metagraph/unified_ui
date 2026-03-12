defmodule WebUi.Router do
  @moduledoc """
  Canonical route table for SPA shell, static assets, and websocket transport.
  """

  alias WebUi.Endpoint
  alias WebUi.TypedError

  @required_route_ids [:spa_shell, :assets, :runtime_socket]

  @type route :: %{
          id: atom(),
          method: String.t(),
          path: String.t(),
          kind: :http | :websocket
        }

  @spec required_route_ids() :: [atom()]
  def required_route_ids, do: @required_route_ids

  @spec routes() :: [route()]
  def routes do
    spec = Endpoint.route_spec()

    [
      %{id: :spa_shell, method: "GET", path: spec.spa.path, kind: :http},
      %{id: :assets, method: "GET", path: spec.assets.path, kind: :http},
      %{id: :runtime_socket, method: "GET", path: spec.websocket.path, kind: :websocket}
    ]
  end

  @spec validate_required_routes([route()]) :: :ok | {:error, TypedError.t()}
  def validate_required_routes(route_table \\ routes()) when is_list(route_table) do
    ids = Enum.map(route_table, & &1.id)
    missing = Enum.reject(@required_route_ids, &(&1 in ids))

    case missing do
      [] ->
        :ok

      _ ->
        {:error,
         TypedError.new(
           "router.missing_required_routes",
           "validation",
           false,
           %{missing_route_ids: missing}
         )}
    end
  end

  @spec route_for(String.t(), String.t()) :: {:ok, route()} | :error
  def route_for(method, path) when is_binary(method) and is_binary(path) do
    norm_method = String.upcase(method)

    Enum.find(routes(), :error, fn route ->
      route.method == norm_method and route_match?(route.path, path)
    end)
    |> case do
      :error -> :error
      route -> {:ok, route}
    end
  end

  def route_for(_method, _path), do: :error

  defp route_match?("/assets/*path", path), do: String.starts_with?(path, "/assets/")
  defp route_match?(expected, path), do: expected == path
end
