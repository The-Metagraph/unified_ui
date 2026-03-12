defmodule UnifiedUi.Adapters.Desktop.ServerTest do
  use ExUnit.Case, async: true

  alias UnifiedUi.Adapters.Desktop.Server
  alias UnifiedIUR.Widgets

  describe "lifecycle" do
    test "returns :error for state and iur before first render" do
      assert {:ok, server} = Server.start_link()

      assert :error = Server.state(server)
      assert :error = Server.current_iur(server)
    end

    test "renders and stores renderer state" do
      iur_tree = %Widgets.Text{content: "Desktop server"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, renderer_state} = Server.render(server, iur_tree)
      assert renderer_state.platform == :desktop
      assert {:ok, ^renderer_state} = Server.state(server)
      assert {:ok, ^iur_tree} = Server.current_iur(server)
    end

    test "update/3 behaves like render/3 when state is not initialized" do
      iur_tree = %Widgets.Text{content: "First update initializes"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, renderer_state} = Server.update(server, iur_tree)
      assert renderer_state.platform == :desktop
      assert {:ok, ^iur_tree} = Server.current_iur(server)
    end

    test "update/3 updates existing renderer state" do
      initial = %Widgets.Text{content: "Initial"}
      updated = %Widgets.Text{content: "Updated"}
      assert {:ok, server} = Server.start_link()

      assert {:ok, initial_state} = Server.render(server, initial)
      assert {:ok, updated_state} = Server.update(server, updated)

      assert updated_state.platform == :desktop
      assert updated_state.version >= initial_state.version
      assert updated_state != initial_state
      assert {:ok, ^updated} = Server.current_iur(server)
    end

    test "merges default render options with per-call options" do
      assert {:ok, server} = Server.start_link(render_opts: [window_title: "Default Title"])

      assert {:ok, renderer_state} =
               Server.render(server, %Widgets.Text{content: "opts"}, window_title: "Override")

      assert renderer_state.config[:window_title] == "Override"
    end

    test "stop/2 stops the server process" do
      assert {:ok, server} = Server.start_link()
      assert Process.alive?(server)

      assert :ok = Server.stop(server)
      refute Process.alive?(server)
    end
  end
end
