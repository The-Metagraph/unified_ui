defmodule WebUi.Renderer.Canonical do
  @moduledoc """
  Canonical IUR renderer for web_ui.

  This module maps UnifiedIUR canonical elements to native web_ui widgets.
  It ensures that canonical rendering reuses the same widget model as
  direct native rendering, maintaining convergence between the two paths.
  """

  alias UnifiedIUR.Element
  alias WebUi.Widgets.Native.Widget
  alias WebUi.Widgets.Foundational

  # Module attribute for foundational kinds - must be defined before use
  @foundational_kinds [
    :text,
    :label,
    :icon,
    :image,
    :button,
    :link,
    :separator,
    :spacer,
    :content
  ]

  @type result :: {:ok, Widget.t()} | {:error, term()}

  @doc """
  Renders a UnifiedIUR element to a native web_ui widget.

  ## Examples

      iex> element = UnifiedIUR.Widgets.Foundational.text("Hello")
      iex> {:ok, widget} = WebUi.Renderer.Canonical.render(element)

  """
  @spec render(Element.t()) :: result()
  def render(%Element{type: :widget, kind: kind} = element) when kind in @foundational_kinds do
    render_foundational(kind, element)
  end

  def render(%Element{type: :widget, kind: kind}) do
    {:error, {:unsupported_widget_kind, kind}}
  end

  def render(%Element{type: type}) do
    {:error, {:unsupported_element_type, type}}
  end

  # Foundational widget rendering

  defp render_foundational(:text, element) do
    with {:ok, text} <- extract_text_content(element) do
      Widget.create(Foundational.Text, %{value: text})
    end
  end

  defp render_foundational(:label, element) do
    with {:ok, text} <- extract_text_content(element),
         {:ok, html_for} <- extract_label_for(element) do
      props = %{value: text}
      props = if html_for, do: Map.put(props, :html_for, html_for), else: props
      Widget.create(Foundational.Label, props)
    end
  end

  defp render_foundational(:icon, element) do
    with {:ok, icon_data} <- extract_icon(element) do
      Widget.create(Foundational.Icon, %{name: to_string(icon_data.name)})
    end
  end

  defp render_foundational(:image, element) do
    with {:ok, image_data} <- extract_image(element) do
      props = %{
        source: image_data.source,
        alt_text: Map.get(image_data, :alt_text, "")
      }
      Widget.create(Foundational.Image, props)
    end
  end

  defp render_foundational(:button, element) do
    with {:ok, label} <- extract_text_content(element) do
      Widget.create(Foundational.Button, %{label: label})
    end
  end

  defp render_foundational(:link, element) do
    with {:ok, label} <- extract_text_content(element),
         {:ok, target} <- extract_link_target(element) do
      Widget.create(Foundational.Link, %{label: label, target: target})
    end
  end

  defp render_foundational(:separator, _element) do
    Widget.create(Foundational.Separator, %{})
  end

  defp render_foundational(:spacer, element) do
    with {:ok, size} <- extract_spacer_size(element) do
      Widget.create(Foundational.Spacer, %{size: size})
    end
  end

  defp render_foundational(:content, element) do
    with {:ok, children} <- extract_children(element) do
      Widget.create(Foundational.Content, %{}, slots: %{content: children})
    end
  end

  # Content extraction helpers

  defp extract_text_content(element) do
    case get_in(element.attributes, [:content, :text]) do
      nil -> {:error, {:missing_attribute, :content_text}}
      text when is_binary(text) -> {:ok, text}
      other -> {:error, {:invalid_attribute, :content_text, other}}
    end
  end

  defp extract_label_for(element) do
    case get_in(element.attributes, [:label, :html_for]) do
      nil -> {:ok, nil}
      html_for when is_binary(html_for) -> {:ok, html_for}
      other -> {:error, {:invalid_attribute, :html_for, other}}
    end
  end

  defp extract_icon(element) do
    case get_in(element.attributes, [:icon]) do
      nil -> {:error, {:missing_attribute, :icon}}
      icon when is_map(icon) -> {:ok, icon}
      other -> {:error, {:invalid_attribute, :icon, other}}
    end
  end

  defp extract_image(element) do
    case get_in(element.attributes, [:image]) do
      nil -> {:error, {:missing_attribute, :image}}
      image when is_map(image) -> {:ok, image}
      other -> {:error, {:invalid_attribute, :image, other}}
    end
  end

  defp extract_link_target(element) do
    case get_in(element.attributes, [:link, :target]) do
      nil -> {:error, {:missing_attribute, :link_target}}
      target when is_binary(target) -> {:ok, target}
      other -> {:error, {:invalid_attribute, :link_target, other}}
    end
  end

  defp extract_spacer_size(element) do
    case get_in(element.attributes, [:spacer, :size]) do
      nil -> {:ok, :md}
      size when is_atom(size) -> {:ok, size}
      size when is_binary(size) -> {:ok, String.to_atom(size)}
      other -> {:error, {:invalid_attribute, :spacer_size, other}}
    end
  end

  defp extract_children(element) do
    # Recursively render children
    case element.children do
      [] -> {:ok, []}
      children when is_list(children) ->
        rendered_children =
          Enum.map(children, fn
            %Element{} = child ->
              case render(child) do
                {:ok, widget} -> widget
                {:error, _} -> nil
              end

            %UnifiedIUR.Element.Child{element: %Element{} = child_element} ->
              case render(child_element) do
                {:ok, widget} -> widget
                {:error, _} -> nil
              end

            _ ->
              nil
          end)
          |> Enum.reject(&is_nil/1)

        {:ok, rendered_children}
    end
  end

  # Continuity checks

  @doc """
  Compares native and canonical rendering for the same widget type.

  This helps ensure that both paths produce equivalent results.
  """
  @spec compare_rendering(atom(), map(), Element.t()) :: {:ok, :equivalent | :different} | {:error, term()}
  def compare_rendering(widget_module, native_props, canonical_element) do
    with {:ok, native_widget} <- Widget.create(widget_module, native_props),
         {:ok, canonical_widget} <- render(canonical_element) do
      # Compare the rendered HTML output
      # Use the widget_module for both since canonical_widget is the same type
      native_html = apply(widget_module, :render_server, [native_widget.props, []])
      canonical_html = apply(widget_module, :render_server, [canonical_widget.props, []])

      if native_html == canonical_html do
        {:ok, :equivalent}
      else
        {:ok, :different}
      end
    end
  end

  @doc """
  Returns the list of supported foundational widget kinds.
  """
  @spec supported_kinds() :: [atom()]
  def supported_kinds, do: @foundational_kinds

  @doc """
  Checks if a given widget kind is supported.
  """
  @spec supports_kind?(atom()) :: boolean()
  def supports_kind?(kind), do: kind in @foundational_kinds
end
