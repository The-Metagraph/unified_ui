defmodule LiveUi.Widgets.Components.SegmentedButtonGroup do
  @moduledoc """
  Native segmented button group preserving canonical selection meaning.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :segmented_button_group,
    assigns: [:options, :active_value, :disabled, :label, :option_attrs],
    events: [:selection]

  LiveUi.Component.common_attrs()
  attr(:options, :list, default: [])
  attr(:active_value, :any, default: nil)
  attr(:disabled, :boolean, default: false)
  attr(:label, :string, default: nil)
  attr(:option_attrs, :map, default: %{})

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :segmented_button_group, :form_control, %{
          "data-live-ui-disabled" => assigns.disabled
        })
      )

    ~H"""
    <div id={@id} role="group" aria-label={@label} class={@class} {@component_attrs}>
      <button
        :for={option <- @options}
        type="button"
        disabled={@disabled || Support.disabled?(option)}
        aria-pressed={if Support.selected?(option, @active_value), do: "true", else: "false"}
        data-live-ui-segment-value={Support.text(Support.fetch(option, :value))}
        {Map.merge(@option_attrs, Support.attrs(option))}
      ><%= Support.label(option) %></button>
    </div>
    """
  end
end

defmodule LiveUi.Widgets.Components.RuntimeFormShell do
  @moduledoc """
  LiveUi-owned form shell for Phoenix-local realization of canonical form meaning.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :runtime_form_shell,
    slots: [:inner_block],
    assigns: [:fields, :submit_label, :validation_state, :host_adapter_hints, :form_attrs],
    events: [:submit, :change]

  LiveUi.Component.common_attrs()
  attr(:fields, :list, default: [])
  attr(:submit_label, :string, default: "Submit")
  attr(:validation_state, :string, default: nil)
  attr(:host_adapter_hints, :map, default: %{})
  attr(:form_attrs, :map, default: %{})
  slot(:inner_block)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :runtime_form_shell, :form_control, %{
          "data-live-ui-validation-state" => assigns.validation_state,
          "data-live-ui-host-adapter" => adapter_hint(assigns.host_adapter_hints)
        })
      )

    ~H"""
    <form id={@id} class={@class} {@component_attrs} {@form_attrs}>
      <label :for={field <- @fields} data-live-ui-form-field={Support.text(Support.fetch(field, :name))}>
        <span><%= Support.label(field, Support.text(Support.fetch(field, :name))) %></span>
        <input
          name={Support.text(Support.fetch(field, :name))}
          type={Support.text(Support.fetch(field, :type, "text"))}
          value={Support.text(Support.fetch(field, :value))}
          {Support.attrs(field)}
        />
      </label>
      <%= render_slot(@inner_block) %>
      <button type="submit"><%= @submit_label %></button>
    </form>
    """
  end

  defp adapter_hint(hints) do
    hints
    |> Support.fetch(:live_ui, %{})
    |> Support.fetch(:adapter)
  end
end

defmodule LiveUi.Widgets.Components.ChatComposer do
  @moduledoc """
  Native chat composer with message text and tool slots.
  """

  alias LiveUi.Widgets.Components.Support

  use LiveUi.Component,
    family: :components,
    name: :chat_composer,
    slots: [:tools],
    assigns: [
      :name,
      :value,
      :placeholder,
      :rows,
      :send_label,
      :disabled,
      :form_attrs,
      :input_attrs,
      :send_attrs
    ],
    events: [:send, :change]

  LiveUi.Component.common_attrs()
  attr(:name, :string, default: "message")
  attr(:value, :string, default: "")
  attr(:placeholder, :string, default: nil)
  attr(:rows, :integer, default: 3)
  attr(:send_label, :string, default: "Send")
  attr(:disabled, :boolean, default: false)
  attr(:form_attrs, :map, default: %{})
  attr(:input_attrs, :map, default: %{})
  attr(:send_attrs, :map, default: %{})
  slot(:tools)

  @impl true
  def render(assigns) do
    assigns =
      assign(
        assigns,
        :component_attrs,
        Support.component_attrs(assigns, :chat_composer, :form_control, %{
          "data-live-ui-disabled" => assigns.disabled
        })
      )

    ~H"""
    <form id={@id} class={@class} {@component_attrs} {@form_attrs}>
      <textarea name={@name} rows={@rows} placeholder={@placeholder} disabled={@disabled} {@input_attrs}><%= @value %></textarea>
      <div :if={@tools != []} data-live-ui-composer-slot="tools"><%= render_slot(@tools) %></div>
      <button type="submit" disabled={@disabled} {@send_attrs}><%= @send_label %></button>
    </form>
    """
  end
end
