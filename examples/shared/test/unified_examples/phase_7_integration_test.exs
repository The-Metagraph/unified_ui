defmodule UnifiedExamples.Phase7IntegrationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias UnifiedExamples.Shared.Maintenance
  alias UnifiedExamples.Shared.ReleaseReadiness
  alias UnifiedExamples.Shared.Tooling
  alias UnifiedExamples.Shared.Validation

  @moduletag timeout: 300_000

  @proof_apps ~w(text button text_input)
  @advanced_apps ~w(overlay viewport canvas cluster_dashboard)

  test "proof apps boot through phx.server-compatible launch descriptors and Phoenix entrypoints" do
    Enum.each(@proof_apps, fn directory ->
      descriptor = Tooling.launch_descriptor(directory)
      assert {:ok, smoke} = Tooling.smoke_launch(directory)

      assert descriptor.argv == ["mix", "phx.server"]
      assert descriptor.command =~ "mix phx.server"
      assert descriptor.url == smoke.url
      assert smoke.status == 200
      assert smoke.body =~ "data-example-directory=\"examples/#{directory}\""
      assert smoke.body =~ "data-live-ui-widget="
    end)
  end

  test "advanced overlay, display, and operational apps mount through the same Phoenix runtime contract" do
    Enum.each(@advanced_apps, fn directory ->
      assert {:ok, metadata} = Tooling.review_metadata(directory)
      assert {:ok, smoke} = Tooling.smoke_launch(directory)
      assert {:ok, report} = Tooling.preview(directory, :report)

      assert metadata.browser_runnable?
      assert metadata.launch_path == "/"
      assert metadata.launch_command =~ "mix phx.server"
      assert smoke.status == 200
      assert smoke.body =~ "data-example-directory=\"examples/#{directory}\""
      assert report =~ "browser_runnable?: true"
      assert report =~ "launch_command:"
    end)
  end

  test "suite validation and release workflows enforce the Phoenix LiveView launch contract" do
    assert Validation.report().valid?
    assert ReleaseReadiness.report().valid?
    assert Maintenance.report().valid?

    validate_output =
      capture_io(fn ->
        Mix.Tasks.Examples.Validate.run(["--strict"])
      end)

    release_output =
      capture_io(fn ->
        Mix.Tasks.Examples.Release.run(["--strict"])
      end)

    assert validate_output =~ "Example suite validation"
    assert validate_output =~ "release_valid?: true"
    assert release_output =~ "Example suite maintainer workflow"
    assert release_output =~ "mix examples.launch <directory> --smoke-test"
    assert release_output =~ "validation_valid?: true"
  end
end
