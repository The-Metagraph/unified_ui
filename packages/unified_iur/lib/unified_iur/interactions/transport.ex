defmodule UnifiedIUR.Interactions.Transport do
  @moduledoc """
  Shared boundary-fixture and validation helpers for canonical navigation
  transitions crossing runtime package boundaries.
  """

  alias UnifiedIUR.{Fixtures, Interaction}

  @extension_key :unified_iur_boundary
  @summary_key :unified_iur_boundary_summary
  @forbidden_navigation_keys [
    :route,
    :path,
    :url,
    :uri,
    :router,
    :helper,
    :module,
    :runtime_module,
    :live_action
  ]
  @navigation_actions Interaction.navigation_actions()

  @type boundary_descriptor :: %{
          family: :navigation,
          intent: atom() | String.t() | nil,
          source_context: map(),
          target: map(),
          metadata: map()
        }

  @type review_summary :: %{
          family: :navigation,
          intent: atom() | String.t() | nil,
          action: atom() | String.t() | nil,
          screen: atom() | String.t() | nil,
          modal: atom() | String.t() | nil,
          params?: boolean(),
          targetless?: boolean()
        }

  @spec extension_key() :: atom()
  def extension_key, do: @extension_key

  @spec summary_key() :: atom()
  def summary_key, do: @summary_key

  @spec forbidden_navigation_keys() :: [atom()]
  def forbidden_navigation_keys, do: @forbidden_navigation_keys

  @spec boundary_fixture_ids() :: [String.t()]
  def boundary_fixture_ids do
    Fixtures.navigation_ids()
  end

  @spec boundary_fixtures() :: [map()]
  def boundary_fixtures do
    Enum.map(boundary_fixture_ids(), &boundary_fixture!/1)
  end

  @spec boundary_fixture(String.t()) :: {:ok, map()} | :error
  def boundary_fixture(id) when is_binary(id) do
    case Fixtures.navigation_fixture(id) do
      {:ok, fixture} ->
        descriptor = boundary_descriptor(fixture.interaction)
        summary = summarize_boundary_descriptor(descriptor)

        {:ok,
         %{
           id: fixture.id,
           description: fixture.description,
           semantics: fixture.semantics,
           snapshot_path: fixture.snapshot_path,
           signal_data: fixture.interaction.payload,
           extensions: boundary_extensions(fixture.interaction),
           descriptor: descriptor,
           summary: summary,
           interaction: fixture.interaction
         }}

      :error ->
        :error
    end
  end

  @spec boundary_fixture!(String.t()) :: map()
  def boundary_fixture!(id) do
    case boundary_fixture(id) do
      {:ok, fixture} -> fixture
      :error -> raise ArgumentError, "unknown boundary fixture #{inspect(id)}"
    end
  end

  @spec boundary_descriptor(Interaction.t() | map() | keyword()) :: boundary_descriptor()
  def boundary_descriptor(input) do
    interaction = Interaction.new(input)

    %{
      family: :navigation,
      intent: interaction.intent,
      source_context: normalize_map(interaction.source),
      target: normalize_map(interaction.target),
      metadata: normalize_map(interaction.metadata)
    }
  end

  @spec boundary_extensions(Interaction.t() | map() | keyword()) :: map()
  def boundary_extensions(input) do
    descriptor = boundary_descriptor(input)

    %{
      @extension_key => descriptor,
      @summary_key => summarize_boundary_descriptor(descriptor)
    }
  end

  @spec summarize_boundary_descriptor(boundary_descriptor() | map() | keyword()) ::
          review_summary()
  def summarize_boundary_descriptor(descriptor) do
    descriptor = normalize_descriptor(descriptor)
    navigation = Interaction.navigation_descriptor(descriptor.target) || %{}

    %{
      family: :navigation,
      intent: descriptor.intent,
      action: Map.get(navigation, :action),
      screen: Map.get(navigation, :screen),
      modal: Map.get(navigation, :modal),
      params?: navigation_params?(navigation),
      targetless?: targetless_navigation?(navigation)
    }
  end

  @spec validate_boundary_fixture(map()) :: :ok | {:error, term()}
  def validate_boundary_fixture(fixture) when is_map(fixture) do
    with :ok <- validate_boundary_payload(Map.get(fixture, :signal_data)),
         :ok <- validate_boundary_extensions(Map.get(fixture, :extensions)) do
      :ok
    end
  end

  @spec validate_boundary_payload(map() | nil) :: :ok | {:error, term()}
  def validate_boundary_payload(payload) when is_map(payload) or is_nil(payload), do: :ok

  def validate_boundary_payload(payload),
    do: {:error, {:invalid_boundary_payload, payload}}

  @spec validate_boundary_extensions(map() | keyword()) :: :ok | {:error, term()}
  def validate_boundary_extensions(extensions) when is_map(extensions) or is_list(extensions) do
    extensions = normalize_map(extensions)

    descriptor =
      Map.get(extensions, @extension_key) || Map.get(extensions, Atom.to_string(@extension_key))

    summary =
      Map.get(extensions, @summary_key) || Map.get(extensions, Atom.to_string(@summary_key))

    with %{} <- descriptor || {:error, :missing_boundary_descriptor},
         :ok <- validate_boundary_descriptor(descriptor),
         :ok <- validate_summary(summary, descriptor) do
      :ok
    else
      {:error, _reason} = error -> error
      _other -> {:error, :missing_boundary_descriptor}
    end
  end

  def validate_boundary_extensions(extensions),
    do: {:error, {:invalid_boundary_extensions, extensions}}

  @spec validate_boundary_descriptor(boundary_descriptor() | map() | keyword()) ::
          :ok | {:error, term()}
  def validate_boundary_descriptor(descriptor) do
    descriptor = normalize_descriptor(descriptor)
    navigation = descriptor.target |> raw_navigation_target() |> normalize_map()

    with :ok <- validate_descriptor_family(descriptor.family),
         :ok <- validate_required_maps(descriptor),
         :ok <- validate_forbidden_navigation_keys(navigation),
         %{} <-
           normalized_navigation(descriptor.target) || {:error, :missing_navigation_descriptor},
         :ok <- validate_navigation_descriptor(normalized_navigation(descriptor.target)) do
      :ok
    else
      {:error, _reason} = error -> error
      _other -> {:error, :missing_navigation_descriptor}
    end
  end

  defp validate_descriptor_family(:navigation), do: :ok
  defp validate_descriptor_family(family), do: {:error, {:invalid_boundary_family, family}}

  defp validate_required_maps(descriptor) do
    with :ok <- validate_map_field(descriptor.source_context, :source_context),
         :ok <- validate_map_field(descriptor.target, :target),
         :ok <- validate_map_field(descriptor.metadata, :metadata) do
      :ok
    end
  end

  defp validate_map_field(value, _field) when is_map(value), do: :ok
  defp validate_map_field(value, field), do: {:error, {:invalid_field, field, value}}

  defp validate_forbidden_navigation_keys(navigation) do
    leaked =
      navigation
      |> Map.keys()
      |> Enum.filter(&forbidden_navigation_key?/1)

    if leaked == [] do
      :ok
    else
      {:error, {:forbidden_navigation_keys, leaked}}
    end
  end

  defp validate_navigation_descriptor(nil), do: {:error, :missing_navigation_descriptor}

  defp validate_navigation_descriptor(descriptor) do
    descriptor = normalize_map(descriptor)
    action = Map.get(descriptor, :action)

    with :ok <- validate_action(action),
         :ok <- validate_action_targets(action, descriptor),
         :ok <- validate_optional_map(Map.get(descriptor, :params), :params),
         :ok <- validate_optional_map(Map.get(descriptor, :metadata), :metadata) do
      :ok
    end
  end

  defp validate_action(action) when action in @navigation_actions, do: :ok

  defp validate_action(action) when is_binary(action) do
    if action in Enum.map(@navigation_actions, &Atom.to_string/1) do
      :ok
    else
      {:error, {:invalid_navigation_action, action}}
    end
  end

  defp validate_action(action), do: {:error, {:invalid_navigation_action, action}}

  defp validate_action_targets(action, descriptor) when action in [:navigate_to, "navigate_to"] do
    require_field(descriptor, :screen)
  end

  defp validate_action_targets(action, descriptor)
       when action in [:replace_with, "replace_with"] do
    require_field(descriptor, :screen)
  end

  defp validate_action_targets(action, descriptor) when action in [:open_modal, "open_modal"] do
    require_field(descriptor, :modal)
  end

  defp validate_action_targets(action, descriptor)
       when action in [:go_back, "go_back", :go_forward, "go_forward"] do
    reject_fields(descriptor, [:screen, :modal])
  end

  defp validate_action_targets(_action, descriptor) do
    reject_fields(descriptor, [:screen])
  end

  defp require_field(descriptor, field) do
    case Map.get(descriptor, field) do
      nil -> {:error, {:missing_field, field}}
      "" -> {:error, {:missing_field, field}}
      _value -> :ok
    end
  end

  defp reject_fields(descriptor, fields) do
    unexpected =
      Enum.filter(fields, fn field ->
        case Map.get(descriptor, field) do
          nil -> false
          "" -> false
          _value -> true
        end
      end)

    if unexpected == [] do
      :ok
    else
      {:error, {:unexpected_fields, unexpected}}
    end
  end

  defp validate_optional_map(nil, _field), do: :ok
  defp validate_optional_map(value, _field) when is_map(value), do: :ok
  defp validate_optional_map(value, field), do: {:error, {:invalid_field, field, value}}

  defp validate_summary(nil, descriptor) do
    {:error, {:missing_boundary_summary, summarize_boundary_descriptor(descriptor)}}
  end

  defp validate_summary(summary, descriptor) when is_map(summary) do
    if normalize_map(summary) == summarize_boundary_descriptor(descriptor) do
      :ok
    else
      {:error, {:invalid_boundary_summary, summary}}
    end
  end

  defp validate_summary(summary, _descriptor), do: {:error, {:invalid_boundary_summary, summary}}

  defp normalize_descriptor(descriptor) do
    descriptor = normalize_map(descriptor)

    %{
      family: Map.get(descriptor, :family) || Map.get(descriptor, "family"),
      intent: Map.get(descriptor, :intent) || Map.get(descriptor, "intent"),
      source_context:
        normalize_map(
          Map.get(descriptor, :source_context) || Map.get(descriptor, "source_context") || %{}
        ),
      target: normalize_map(Map.get(descriptor, :target) || Map.get(descriptor, "target") || %{}),
      metadata:
        normalize_map(Map.get(descriptor, :metadata) || Map.get(descriptor, "metadata") || %{})
    }
  end

  defp normalized_navigation(target) do
    Interaction.navigation_descriptor(target)
  end

  defp raw_navigation_target(target) do
    target = normalize_map(target)
    Map.get(target, :navigation) || Map.get(target, "navigation") || %{}
  end

  defp navigation_params?(navigation) do
    navigation
    |> Map.get(:params, %{})
    |> normalize_map()
    |> Kernel.!=(%{})
  end

  defp targetless_navigation?(navigation) do
    is_nil(Map.get(navigation, :screen)) and is_nil(Map.get(navigation, :modal))
  end

  defp forbidden_navigation_key?(key) when is_atom(key),
    do: key in @forbidden_navigation_keys

  defp forbidden_navigation_key?(key) when is_binary(key) do
    key in Enum.map(@forbidden_navigation_keys, &Atom.to_string/1)
  end

  defp forbidden_navigation_key?(_key), do: false

  defp normalize_map(map) when is_map(map), do: Map.new(map)
  defp normalize_map(list) when is_list(list), do: Enum.into(list, %{})
  defp normalize_map(_value), do: %{}
end
