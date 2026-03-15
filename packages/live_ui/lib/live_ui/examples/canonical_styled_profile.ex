defmodule LiveUi.Examples.CanonicalStyledProfile do
  @moduledoc """
  Maintained canonical styling example for the profile continuity workflow.
  """

  alias UnifiedIUR.Container
  alias UnifiedIUR.Widgets.{Foundational, Input}

  def element do
    Container.box(
      [
        Foundational.text("Profile",
          id: "profile-title",
          style: %{
            emphasis: %{tone: :success},
            extra: %{class: "profile-copy"}
          },
          theme: %{id: :live_ui}
        ),
        Foundational.text("Connected",
          id: "profile-status",
          style: %{
            emphasis: %{tone: :success},
            extra: %{class: "profile-copy"}
          },
          theme: %{id: :live_ui}
        ),
        Input.text_input(
          id: "profile-name",
          name: "name",
          value: "Pascal",
          placeholder: "Name",
          style: %{extra: %{class: "profile-name-input"}},
          theme: %{id: :live_ui}
        ),
        Foundational.button("Save",
          id: "profile-save",
          style: %{extra: %{class: "profile-save"}},
          theme: %{id: :live_ui}
        )
      ],
      id: "profile-shell",
      padding: "lg",
      border: "subtle",
      background: "panel",
      style: %{extra: %{class: "profile-shell"}},
      theme: %{id: :live_ui}
    )
  end

  def metadata do
    %{
      id: :canonical_styled_profile,
      title: "Canonical Styled Profile",
      families: [:styling, :input, :continuity],
      comparable_to: :native_styled_profile,
      summary: "Canonical styled profile that reuses the native runtime surface."
    }
  end
end
