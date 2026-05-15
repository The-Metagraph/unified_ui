defmodule UnifiedUi.Css.Stylesheet do
  @moduledoc """
  Authored CSS stylesheet block declared in the `UnifiedUi` DSL.
  """

  @type t :: %__MODULE__{
          __identifier__: atom() | nil,
          id: atom() | nil,
          source: String.t(),
          authored_ref: [atom()] | nil,
          summary: String.t() | nil,
          order: non_neg_integer() | nil
        }

  defstruct __identifier__: nil,
            id: nil,
            source: "",
            authored_ref: nil,
            summary: nil,
            order: nil

  @spec new(keyword() | map() | t()) :: t()
  def new(%__MODULE__{} = stylesheet), do: normalize(stylesheet)
  def new(stylesheet) when is_list(stylesheet), do: stylesheet |> Enum.into(%{}) |> new()

  def new(stylesheet) when is_map(stylesheet) do
    %__MODULE__{
      __identifier__: fetch(stylesheet, :__identifier__),
      id: fetch(stylesheet, :id),
      source: fetch(stylesheet, :source, ""),
      authored_ref: fetch(stylesheet, :authored_ref),
      summary: fetch(stylesheet, :summary),
      order: fetch(stylesheet, :order)
    }
    |> normalize()
  end

  @spec summary(t()) :: map()
  def summary(%__MODULE__{} = stylesheet) do
    %{
      id: stylesheet.id,
      authored_ref: stylesheet.authored_ref,
      summary: stylesheet.summary,
      order: stylesheet.order,
      source_bytes: byte_size(stylesheet.source || "")
    }
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
    |> Map.new()
  end

  defp normalize(%__MODULE__{} = stylesheet) do
    %__MODULE__{
      stylesheet
      | source: stylesheet.source || "",
        authored_ref: normalize_authored_ref(stylesheet.authored_ref)
    }
  end

  defp normalize_authored_ref(nil), do: nil
  defp normalize_authored_ref(value), do: List.wrap(value)

  defp fetch(source, key, default \\ nil) do
    Map.get(source, key, Map.get(source, Atom.to_string(key), default))
  end
end
