defmodule WebUi.EndpointTest do
  use ExUnit.Case, async: true

  alias WebUi.Endpoint
  alias WebUi.TypedError

  describe "route_spec/0" do
    test "returns canonical route paths" do
      spec = Endpoint.route_spec()

      assert spec.spa.path == "/"
      assert spec.assets.path == "/assets/*path"
      assert spec.websocket.path == "/socket/webui"
      assert spec.websocket.transport == "websocket"
    end
  end

  describe "validate_startup_config/1" do
    test "accepts valid startup config" do
      config = %{spa_path: "/", assets_path: "/assets", websocket_path: "/socket/webui"}

      assert {:ok, ^config} = Endpoint.validate_startup_config(config)
    end

    test "rejects missing required keys" do
      assert {:error, %TypedError{} = error} = Endpoint.validate_startup_config(%{spa_path: "/"})

      assert error.error_code == "endpoint.missing_required_keys"
      assert error.category == "validation"
      assert error.retryable == false
    end

    test "rejects invalid path values" do
      config = %{spa_path: "/", assets_path: "assets", websocket_path: "/socket/webui"}

      assert {:error, %TypedError{} = error} = Endpoint.validate_startup_config(config)
      assert error.error_code == "endpoint.invalid_route_path"
      assert error.details[:invalid_keys] == [:assets_path]
    end

    test "rejects non-map config" do
      assert {:error, %TypedError{} = error} = Endpoint.validate_startup_config(:invalid)
      assert error.error_code == "endpoint.invalid_config_shape"
    end
  end
end
