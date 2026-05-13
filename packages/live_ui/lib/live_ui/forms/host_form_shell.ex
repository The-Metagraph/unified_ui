defmodule LiveUi.Forms.HostFormShell do
  @moduledoc """
  Host-owned native form shell for runtime-managed LiveView form lifecycles.
  """

  use LiveUi.Component,
    family: :input,
    name: :host_form_shell,
    slots: [:inner_block],
    events: [:submit, :change]

  LiveUi.Component.common_attrs()
  attr(:owner, :string, default: "host")
  attr(:lifecycle, :string, default: "host_owned")
  attr(:submit_intent, :string, default: nil)
  attr(:validation_summary, :string, default: nil)
  attr(:action_placement, :string, default: "footer")
  attr(:autocomplete, :boolean, default: true)
  slot(:inner_block)

  @impl true
  def render(assigns) do
    ~H"""
    <form
      id={@id}
      data-live-ui-widget="host-form-shell"
      data-live-ui-owner={@owner}
      data-live-ui-lifecycle={@lifecycle}
      data-live-ui-submit-intent={@submit_intent}
      data-live-ui-action-placement={@action_placement}
      data-live-ui-tone={@tone}
      data-live-ui-variant={@variant}
      data-live-ui-state={@state}
      class={@class}
      autocomplete={if @autocomplete, do: "on", else: "off"}
      aria-describedby={if @validation_summary, do: "#{@id}-validation-summary"}
      {@rest}
    >
      <div data-live-ui-host-form-slot="body"><%= render_slot(@inner_block) %></div>
      <p
        :if={@validation_summary}
        id={"#{@id}-validation-summary"}
        data-live-ui-host-form-validation-summary
      ><%= @validation_summary %></p>
    </form>
    """
  end
end
