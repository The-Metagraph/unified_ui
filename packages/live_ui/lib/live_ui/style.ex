defmodule LiveUi.Style do
  @moduledoc """
  Native style-resolution helpers for direct `live_ui` usage and canonical
  `UnifiedIUR` lowering.
  """

  alias LiveUi.Theme
  alias UnifiedIUR.Element
  alias UnifiedIUR.Style, as: CanonicalStyle

  @type t :: %__MODULE__{
          component: atom() | String.t() | nil,
          theme_id: atom() | String.t() | nil,
          tone: String.t() | nil,
          variant: String.t() | nil,
          state: String.t() | nil,
          class: String.t() | nil,
          attrs: map(),
          role: String.t() | nil,
          canonical: CanonicalStyle.t()
        }

  @enforce_keys [:canonical, :attrs]
  defstruct component: nil,
            theme_id: nil,
            tone: nil,
            variant: nil,
            state: nil,
            class: nil,
            attrs: %{},
            role: nil,
            canonical: %CanonicalStyle{}

  @spec new(keyword() | map() | t() | nil) :: t()
  def new(nil), do: %__MODULE__{canonical: CanonicalStyle.new(nil), attrs: %{}}

  def new(%__MODULE__{} = style) do
    %__MODULE__{
      component: style.component,
      theme_id: style.theme_id,
      tone: normalize_optional(style.tone),
      variant: normalize_optional(style.variant),
      state: normalize_optional(style.state),
      class: normalize_class(style.class),
      attrs: normalize_attrs(style.attrs),
      role: normalize_optional(style.role),
      canonical: CanonicalStyle.new(style.canonical)
    }
  end

  def new(style) when is_list(style), do: style |> Enum.into(%{}) |> new()

  def new(style) when is_map(style) do
    %__MODULE__{
      component: fetch(style, :component),
      theme_id: fetch(style, :theme_id),
      tone: normalize_optional(fetch(style, :tone)),
      variant: normalize_optional(fetch(style, :variant)),
      state: normalize_optional(fetch(style, :state)),
      class: normalize_class(fetch(style, :class)),
      attrs: normalize_attrs(fetch(style, :attrs, %{})),
      role: normalize_optional(fetch(style, :role)),
      canonical: CanonicalStyle.new(fetch(style, :canonical, fetch(style, :local_style)))
    }
  end

  @spec resolve(Theme.t() | keyword() | map() | nil, atom() | String.t(), keyword() | map()) ::
          t()
  def resolve(theme, component, opts \\ []) do
    theme = Theme.new(theme)
    opts = normalize_map(opts)
    native = Theme.component_profile(theme, component)
    local_style = fetch(opts, :local_style, %{}) |> CanonicalStyle.new()

    tone =
      first_present([
        fetch(opts, :tone),
        emphasis_tone(local_style),
        fetch(opts, :role),
        fetch(native, :tone)
      ])

    variant =
      first_present([
        fetch(opts, :variant),
        fetch(native, :variant)
      ])

    state =
      first_present([
        fetch(opts, :state),
        fetch(native, :state)
      ])

    canonical =
      Theme.resolve_style(theme, component,
        variant: denormalize_optional(variant),
        state: denormalize_optional(state),
        token_refs: fetch(opts, :token_refs, []),
        local_style: local_style
      )

    resolved_theme_id = fetch(opts, :theme_id, theme.id)

    native_attrs =
      native
      |> fetch(:attrs, %{})
      |> Map.merge(normalize_attrs(fetch(opts, :attrs, %{})))
      |> maybe_put("data-live-ui-theme", resolved_theme_id)
      |> maybe_put("data-live-ui-style-component", component)
      |> maybe_put("data-live-ui-style-role", fetch(opts, :role))

    %__MODULE__{
      component: component,
      theme_id: resolved_theme_id,
      tone: normalize_optional(tone),
      variant: normalize_optional(variant),
      state: normalize_optional(state),
      class:
        merge_classes([
          fetch(native, :class),
          class_for_variant(native, variant),
          class_for_state(native, state),
          class_from_local_style(local_style),
          fetch(opts, :class)
        ]),
      attrs: native_attrs,
      role: normalize_optional(fetch(opts, :role)),
      canonical: canonical
    }
  end

  @spec merge(t() | keyword() | map() | nil, t() | keyword() | map() | nil) :: t()
  def merge(parent, child) do
    parent = new(parent)
    child = new(child)

    %__MODULE__{
      component: child.component || parent.component,
      theme_id: child.theme_id || parent.theme_id,
      tone: child.tone || parent.tone,
      variant: child.variant || parent.variant,
      state: child.state || parent.state,
      class: merge_classes([parent.class, child.class]),
      attrs: Map.merge(parent.attrs, child.attrs),
      role: child.role || parent.role,
      canonical: CanonicalStyle.merge(parent.canonical, child.canonical)
    }
  end

  @spec component_assigns(atom() | String.t(), keyword() | map()) :: map()
  def component_assigns(component, opts \\ []) do
    theme = fetch(normalize_map(opts), :theme, Theme.default())
    attrs = normalize_map(fetch(normalize_map(opts), :assigns, %{}))
    apply(attrs, theme, component, opts)
  end

  @spec apply(
          map() | keyword(),
          Theme.t() | keyword() | map() | nil,
          atom() | String.t(),
          keyword() | map()
        ) ::
          map()
  def apply(assigns, theme, component, opts \\ []) when is_map(assigns) or is_list(assigns) do
    assigns = normalize_map(assigns)
    opts = normalize_map(opts)

    profile =
      resolve(theme, component, %{
        tone: fetch(opts, :tone, fetch(assigns, :tone)),
        variant: fetch(opts, :variant, fetch(assigns, :variant)),
        state: fetch(opts, :state, fetch(assigns, :state)),
        class: fetch(opts, :class, fetch(assigns, :class)),
        role: fetch(opts, :role),
        token_refs: fetch(opts, :token_refs, []),
        local_style: fetch(opts, :style, fetch(assigns, :style)),
        attrs: fetch(opts, :attrs, %{})
      })

    rest =
      assigns
      |> fetch(:rest, %{})
      |> normalize_attrs()
      |> Map.merge(profile.attrs)

    metadata =
      assigns
      |> fetch(:metadata, %{})
      |> normalize_map()
      |> Map.put(:style_profile, profile)

    assigns
    |> maybe_put(:tone, profile.tone)
    |> maybe_put(:variant, profile.variant)
    |> maybe_put(:state, profile.state)
    |> maybe_put(:class, merge_classes([fetch(assigns, :class), profile.class]))
    |> Map.put(:rest, rest)
    |> Map.put(:metadata, metadata)
  end

  @spec from_element(Element.t(), keyword() | map()) :: t()
  def from_element(%Element{} = element, opts \\ []) do
    opts = normalize_map(opts)
    theme = fetch(opts, :theme, Theme.default())
    theme_attachment = normalize_map(Map.get(element.attributes, :theme, %{}))
    local_style = Map.get(element.attributes, :style, %{})

    resolve(theme, element.kind,
      theme_id: fetch(theme_attachment, :id),
      variant: fetch(theme_attachment, :variant),
      state: fetch(theme_attachment, :state),
      role: fetch(theme_attachment, :role),
      token_refs: fetch(theme_attachment, :token_refs, []),
      local_style: local_style,
      class: class_from_local_style(CanonicalStyle.new(local_style)),
      attrs: local_attrs(local_style)
    )
  end

  @spec to_assigns(t() | keyword() | map() | nil) :: map()
  def to_assigns(style_profile) do
    style_profile = new(style_profile)

    %{}
    |> maybe_put(:tone, style_profile.tone)
    |> maybe_put(:variant, style_profile.variant)
    |> maybe_put(:state, style_profile.state)
    |> maybe_put(:class, style_profile.class)
    |> maybe_put(:rest, if(style_profile.attrs == %{}, do: nil, else: style_profile.attrs))
  end

  defp emphasis_tone(%CanonicalStyle{} = style) do
    style.emphasis
    |> normalize_map()
    |> fetch(:tone)
  end

  defp class_from_local_style(%CanonicalStyle{} = style) do
    style.extra
    |> normalize_map()
    |> fetch(:class, fetch(style.extra, :native_class))
    |> normalize_class()
  end

  defp local_attrs(local_style) do
    local_style
    |> CanonicalStyle.new()
    |> Map.get(:extra)
    |> normalize_map()
    |> fetch(:attrs, %{})
    |> normalize_attrs()
  end

  defp class_for_variant(_native_profile, nil), do: nil

  defp class_for_variant(native_profile, variant) do
    native_profile
    |> fetch(:variant_classes, %{})
    |> Map.get(denormalize_optional(variant))
    |> normalize_class()
  end

  defp class_for_state(_native_profile, nil), do: nil

  defp class_for_state(native_profile, state) do
    native_profile
    |> fetch(:state_classes, %{})
    |> Map.get(denormalize_optional(state))
    |> normalize_class()
  end

  defp normalize_attrs(attrs) when is_map(attrs) do
    Map.new(attrs, fn {key, value} -> {to_string(key), to_string(value)} end)
  end

  defp normalize_attrs(_other), do: %{}

  defp normalize_map(nil), do: %{}
  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})

  defp fetch(source, key, default \\ nil) do
    Map.get(source, key, Map.get(source, Atom.to_string(key), default))
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp first_present(values) do
    Enum.find_value(values, fn
      nil -> nil
      "" -> nil
      value -> value
    end)
  end

  defp merge_classes(classes) do
    classes
    |> Enum.flat_map(fn
      nil -> []
      "" -> []
      value when is_binary(value) -> String.split(value, ~r/\s+/, trim: true)
      value -> [to_string(value)]
    end)
    |> Enum.uniq()
    |> case do
      [] -> nil
      values -> Enum.join(values, " ")
    end
  end

  defp normalize_optional(nil), do: nil
  defp normalize_optional(""), do: nil
  defp normalize_optional(value), do: to_string(value)

  defp denormalize_optional(nil), do: nil

  defp denormalize_optional(value) do
    try do
      String.to_existing_atom(value)
    rescue
      ArgumentError -> value
    end
  end

  defp normalize_class(nil), do: nil

  defp normalize_class(value) do
    value
    |> to_string()
    |> String.trim()
    |> case do
      "" -> nil
      trimmed -> trimmed
    end
  end
end
