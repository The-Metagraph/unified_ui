defmodule UnifiedUi.Adapters.Web.ServerTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Web.Server
  alias UnifiedIUR.Widgets

  describe "lifecycle" do
    test "returns :error for state and iur before first render" do
      assert {:ok, server} = Server.start_link()

      assert :error = Server.state(server)
      assert :error = Server.current_iur(server)
    end

    test "renders and stores renderer state" do
      iur_tree = %Widgets.Text{content: "Web server"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, renderer_state} = Server.render(server, iur_tree)
      assert renderer_state.platform == :web
      assert {:ok, ^renderer_state} = Server.state(server)
      assert {:ok, ^iur_tree} = Server.current_iur(server)
    end

    test "update/3 behaves like render/3 when state is not initialized" do
      iur_tree = %Widgets.Text{content: "First update initializes"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, renderer_state} = Server.update(server, iur_tree)
      assert renderer_state.platform == :web
      assert {:ok, ^iur_tree} = Server.current_iur(server)
    end

    test "update/3 updates existing renderer state" do
      initial = %Widgets.Text{content: "Initial"}
      updated = %Widgets.Text{content: "Updated"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, initial_state} = Server.render(server, initial)
      assert {:ok, updated_state} = Server.update(server, updated)

      assert updated_state.platform == :web
      assert updated_state.version >= initial_state.version
      assert updated_state != initial_state
      assert {:ok, ^updated} = Server.current_iur(server)
    end

    test "stop/2 stops the server process" do
      assert {:ok, server} = Server.start_link()
      assert Process.alive?(server)

      assert :ok = Server.stop(server)
      refute Process.alive?(server)
    end
  end

  describe "websocket coordination" do
    test "connect_socket/4 registers a session and emits connected signal" do
      assert {:ok, server} = Server.start_link()

      assert :ok = Server.connect_socket(server, :socket_a, self())
      assert Server.socket_count(server) == 1
      assert %{socket_a: socket_pid} = Server.sockets(server)
      assert socket_pid == self()

      assert_receive {:websocket_signal, signal}
      assert signal.type == "unified.web.connected"
      assert signal.data.data.socket_id == :socket_a
    end

    test "dispatch_event/4 broadcasts converted signal to connected sessions" do
      assert {:ok, server} = Server.start_link()
      assert :ok = Server.connect_socket(server, :socket_a, self())

      assert_receive {:websocket_signal, connected}
      assert connected.type == "unified.web.connected"

      assert {:ok, signal} =
               Server.dispatch_event(
                 server,
                 :click,
                 %{widget_id: :save_button, action: :save},
                 component_id: nil
               )

      assert signal.type == "unified.button.clicked"
      assert signal.data.widget_id == :save_button

      assert_receive {:websocket_signal, delivered}
      assert delivered.type == "unified.button.clicked"
      assert delivered.data.action == :save
      assert delivered.data.platform == :web
    end

    test "disconnect_socket/3 removes a socket and notifies remaining sessions" do
      assert {:ok, server} = Server.start_link()
      assert :ok = Server.connect_socket(server, :self_socket, self())
      assert_receive {:websocket_signal, _connected_self}

      parent = self()
      proxy = spawn_link(fn -> proxy_loop(parent) end)
      assert :ok = Server.connect_socket(server, :proxy_socket, proxy)
      assert_receive {:websocket_signal, connected_again}
      assert connected_again.type == "unified.web.connected"
      assert_receive {:proxy_message, ^proxy, {:websocket_signal, _proxy_connected}}

      assert :ok = Server.disconnect_socket(server, :proxy_socket)
      assert Server.socket_count(server) == 1
      assert %{self_socket: socket_pid} = Server.sockets(server)
      assert socket_pid == self()

      assert_receive {:websocket_signal, disconnected}
      assert disconnected.type == "unified.web.disconnected"
      assert disconnected.data.data.socket_id == :proxy_socket
    end

    test "prunes dead socket processes during signal delivery" do
      assert {:ok, server} = Server.start_link()

      transient =
        spawn_link(fn ->
          receive do
            :stop -> :ok
          end
        end)

      assert :ok = Server.connect_socket(server, :transient, transient)
      send(transient, :stop)
      Process.sleep(10)

      assert {:ok, _signal} = Server.dispatch_event(server, :click, %{widget_id: :ok})
      assert Server.socket_count(server) == 0
      assert Server.sockets(server) == %{}
    end

    test "returns error when connecting dead socket pid" do
      assert {:ok, server} = Server.start_link()
      dead_pid = spawn(fn -> :ok end)
      Process.sleep(10)

      assert {:error, :socket_process_not_alive} =
               Server.connect_socket(server, :dead_socket, dead_pid)
    end

    test "returns error when disconnecting unknown socket" do
      assert {:ok, server} = Server.start_link()
      assert {:error, :socket_not_found} = Server.disconnect_socket(server, :missing_socket)
    end
  end

  defp proxy_loop(parent) do
    receive do
      message ->
        send(parent, {:proxy_message, self(), message})
        proxy_loop(parent)
    end
  end
end
