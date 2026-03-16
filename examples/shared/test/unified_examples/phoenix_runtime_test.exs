defmodule UnifiedExamples.PhoenixRuntimeTest do
  use ExUnit.Case, async: false

  alias UnifiedExamples.Shared.Catalog
  alias UnifiedExamples.Shared.Template
  alias UnifiedExamples.Shared.Tooling

  @moduletag timeout: 120_000

  @proof_apps ~w(text button text_input)
  @foundational_apps Enum.map(Catalog.by_phase(2), & &1.directory)
  @advanced_representatives ~w(row tabs table progress viewport overlay canvas cluster_dashboard)

  test "proof apps boot through their Phoenix LiveView entrypoints" do
    Enum.each(@proof_apps, fn directory ->
      assert {:ok, smoke} = Tooling.smoke_launch(directory)

      assert smoke.status == 200
      assert smoke.path == "/"
      assert smoke.body =~ "data-example-directory=\"examples/#{directory}\""
      assert smoke.body =~ "data-live-ui-widget="
    end)
  end

  test "foundational content, form, and input apps keep the shared theme and style contract" do
    Enum.each(@proof_apps ++ @foundational_apps, fn directory ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)
      assert {:ok, smoke} = Tooling.smoke_launch(directory)

      assert metadata.browser_runnable?
      assert metadata.dev_server_enabled?
      assert metadata.default_theme_id == Template.default_theme_id()
      assert metadata.uses_shared_template
      assert smoke.status == 200
      assert smoke.launch_command =~ "mix phx.server"
      assert smoke.body =~ "data-example-launch="
    end)
  end

  test "advanced layout, overlay, display, data, and operational apps mount through the same runtime pattern" do
    Enum.each(@advanced_representatives, fn directory ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)
      assert {:ok, smoke} = Tooling.smoke_launch(directory)

      assert metadata.browser_runnable?
      assert metadata.dev_server_enabled?
      assert smoke.status == 200
      assert smoke.body =~ "data-example-directory=\"examples/#{directory}\""
      assert smoke.body =~ "data-live-ui-widget="
    end)
  end

  test "proof apps enable the Phoenix endpoint server for direct mix phx.server launches" do
    Enum.each(@proof_apps, fn directory ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)

      assert metadata.dev_server_enabled?
      assert metadata.launch_command =~ "mix phx.server"
    end)
  end
end
