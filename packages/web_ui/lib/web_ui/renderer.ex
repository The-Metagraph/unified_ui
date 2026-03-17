defmodule WebUi.Renderer do
  @moduledoc """
  Package-facing entrypoint for canonical `UnifiedIUR` rendering boundaries.
  """

  alias UnifiedIUR.{Element, Normalize}
  alias WebUi.Renderer.{Error, Mapper}
  alias WebUi.Server.ViewState

  @type responsibility ::
          :canonical_iur_entrypoint
          | :native_widget_reuse
          | :split_runtime_mapping

  @spec responsibilities() :: [responsibility()]
  def responsibilities do
    [
      :canonical_iur_entrypoint,
      :native_widget_reuse,
      :split_runtime_mapping
    ]
  end

  @spec accepts() :: module()
  def accepts, do: Element

  @spec modules() :: [module()]
  def modules do
    [Error, Mapper]
  end

  @spec supported_kinds() :: [atom()]
  def supported_kinds do
    Mapper.supported_kinds()
  end

  @spec render(Element.t() | map() | keyword(), keyword()) ::
          {:ok, [WebUi.Widget.t()]} | {:error, Error.t()}
  def render(input, _opts \\ []) do
    with {:ok, element} <- normalize_input(input),
         {:ok, widget} <- Mapper.element(element) do
      {:ok, [widget]}
    end
  end

  @spec render_view_state(Element.t() | map() | keyword(), keyword()) ::
          {:ok, ViewState.t()} | {:error, Error.t() | WebUi.Server.Error.t()}
  def render_view_state(input, opts \\ []) do
    with {:ok, element} <- normalize_input(input),
         {:ok, widgets} <- render(element, opts) do
      ViewState.from_widgets(
        %{
          id: Keyword.get(opts, :screen_id, screen_id(element)),
          title: Keyword.get(opts, :title, screen_title(element)),
          module: __MODULE__,
          mode: :canonical
        },
        %{},
        widgets,
        %{
          entry: :canonical,
          canonical_kind: element.kind,
          canonical_id: element.id
        },
        revision: Keyword.get(opts, :revision, 0),
        mode: :canonical
      )
    end
  end

  @spec validation_state() :: map()
  def validation_state do
    %{
      canonical_input: :ready,
      foundational_mapping: :ready,
      native_widget_reuse: :ready,
      coverage_boundaries: :ready
    }
  end

  @spec namespace() :: module()
  def namespace, do: __MODULE__

  defp normalize_input(input) do
    case Normalize.element(input) do
      {:ok, element} -> {:ok, element}
      {:error, errors} -> {:error, Error.invalid_input(errors)}
    end
  end

  defp screen_id(%Element{id: id}) when not is_nil(id), do: "canonical:#{id}"
  defp screen_id(%Element{kind: kind}), do: "canonical:#{kind}"

  defp screen_title(%Element{metadata: metadata, kind: kind}) do
    metadata.description ||
      kind |> to_string() |> String.replace("_", " ") |> String.capitalize()
  end
end
