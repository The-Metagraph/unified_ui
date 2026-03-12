defmodule WebUi.RouterTest do
  use ExUnit.Case, async: true

  alias WebUi.Router
  alias WebUi.TypedError

  describe "routes/0" do
    test "contains canonical route ids" do
      ids = Router.routes() |> Enum.map(& &1.id)

      assert ids == [:spa_shell, :assets, :runtime_socket]
      assert :ok == Router.validate_required_routes()
    end

    test "rejects missing required route ids" do
      assert {:error, %TypedError{} = error} =
               Router.validate_required_routes([
                 %{id: :spa_shell, method: "GET", path: "/", kind: :http}
               ])

      assert error.error_code == "router.missing_required_routes"
      assert error.details[:missing_route_ids] == [:assets, :runtime_socket]
    end
  end

  describe "route_for/2" do
    test "resolves spa route" do
      assert {:ok, %{id: :spa_shell}} = Router.route_for("GET", "/")
    end

    test "resolves assets route with wildcard semantics" do
      assert {:ok, %{id: :assets}} = Router.route_for("GET", "/assets/app.css")
    end

    test "resolves websocket route" do
      assert {:ok, %{id: :runtime_socket}} = Router.route_for("GET", "/socket/webui")
    end

    test "returns :error for unknown routes" do
      assert :error == Router.route_for("POST", "/unknown")
    end
  end
end
