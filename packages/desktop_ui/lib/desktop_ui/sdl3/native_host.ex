defmodule DesktopUi.Sdl3.NativeHost do
  @moduledoc """
  Executable SDL3-host skeleton that owns callback lifecycle and native-window
  state behind the framed host protocol.
  """

  alias DesktopUi.Sdl3.{Lifecycle, Protocol}

  # Port-backed stdio reads block until the requested byte count is satisfied.
  # Read one byte at a time so framed host messages can be processed as soon as
  # a complete frame is available.
  @chunk_size 1

  @spec contract() :: map()
  def contract do
    %{
      lifecycle_model: :callback_oriented,
      host_runtime: :external_process,
      first_backend: :sdl_renderer,
      native_window_state: :host_owned,
      placeholder_windows_allowed: true
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :native_host_skeleton_ready

  @spec main() :: no_return()
  def main do
    :io.setopts(:standard_io, encoding: :latin1)

    state = %{
      lifecycle: Lifecycle.scaffold(),
      runtime: nil,
      windows: %{primary_id: nil, sessions: [], continuity: :single_window},
      platform_target: nil,
      presented_frames: 0,
      last_frame: nil
    }

    loop(state, <<>>)
  end

  defp loop(state, buffer) do
    case Protocol.next_message(buffer) do
      {:ok, message, rest} ->
        {next_state, responses, halt?} = handle_message(state, message)
        Enum.each(responses, &write_message/1)

        if halt? do
          :erlang.halt(0)
        else
          loop(next_state, rest)
        end

      :more ->
        case IO.binread(:stdio, @chunk_size) do
          :eof ->
            :erlang.halt(0)

          {:error, reason} ->
            write_message(
              Protocol.error_envelope(:native_host_read_failed, %{reason: inspect(reason)})
            )

            :erlang.halt(1)

          chunk when is_binary(chunk) ->
            loop(state, buffer <> chunk)
        end

      {:error, error} ->
        write_message(
          Protocol.error_envelope(error.reason, error.details, diagnostics: %{phase: error.phase})
        )

        :erlang.halt(1)
    end
  end

  defp handle_message(state, %{family: :boot, kind: :request} = message) do
    payload = message.payload
    runtime = payload[:runtime] || %{}
    windows = payload[:windows] || %{}

    lifecycle =
      Lifecycle.scaffold()
      |> Lifecycle.begin_boot(%{
        runtime_id: runtime[:runtime_id],
        screen_id: runtime[:screen_id],
        platform_target: runtime[:platform_target]
      })
      |> Lifecycle.record_callback(:app_init, :ready)
      |> Lifecycle.record_callback(:app_event, :ready)
      |> Lifecycle.record_callback(:app_iterate, :ready)
      |> Lifecycle.ready()

    next_state = %{
      state
      | lifecycle: lifecycle,
        runtime: runtime,
        windows: normalize_windows(windows),
        platform_target: runtime[:platform_target]
    }

    response =
      Protocol.new_message(
        :boot,
        :ack,
        %{
          lifecycle: Lifecycle.diagnostics(lifecycle),
          host: %{
            backend: :sdl_renderer,
            runtime_state: :running,
            native_window_count: length(next_state.windows.sessions),
            validation_state: validation_state()
          },
          windows: %{
            primary_id: next_state.windows.primary_id,
            continuity: next_state.windows.continuity,
            session_ids: Enum.map(next_state.windows.sessions, & &1.id)
          }
        },
        correlation_id: message.id,
        runtime_id: runtime[:runtime_id],
        screen_id: runtime[:screen_id]
      )

    {next_state, [response], false}
  end

  defp handle_message(state, %{family: :window, kind: :update} = message) do
    windows = normalize_windows(message.payload[:windows] || %{})
    focus_window_id = message.payload[:focus_window_id] || windows.primary_id

    response =
      Protocol.new_message(
        :window,
        :ack,
        %{
          windows: %{
            primary_id: windows.primary_id,
            focus_window_id: focus_window_id,
            continuity: windows.continuity,
            session_ids: Enum.map(windows.sessions, & &1.id)
          }
        },
        correlation_id: message.id,
        runtime_id: get_in(state, [:runtime, :runtime_id]),
        screen_id: get_in(state, [:runtime, :screen_id]),
        window_id: focus_window_id
      )

    {%{state | windows: windows}, [response], false}
  end

  defp handle_message(state, %{family: :shutdown, kind: :request} = message) do
    lifecycle =
      state.lifecycle
      |> Lifecycle.begin_shutdown()
      |> Lifecycle.record_callback(:app_quit, :ready)

    response =
      Protocol.new_message(
        :shutdown,
        :ack,
        %{
          lifecycle: Lifecycle.diagnostics(lifecycle),
          host: %{runtime_state: :stopped}
        },
        correlation_id: message.id,
        runtime_id: get_in(state, [:runtime, :runtime_id]),
        screen_id: get_in(state, [:runtime, :screen_id])
      )

    {%{state | lifecycle: lifecycle}, [response], true}
  end

  defp handle_message(state, %{family: :diagnostics} = message) do
    response =
      Protocol.new_message(
        :diagnostics,
        :ack,
        %{
          lifecycle: Lifecycle.diagnostics(state.lifecycle),
          windows: state.windows,
          platform_target: state.platform_target,
          presented_frames: state.presented_frames,
          last_frame: state.last_frame
        },
        correlation_id: message.id,
        runtime_id: get_in(state, [:runtime, :runtime_id]),
        screen_id: get_in(state, [:runtime, :screen_id])
      )

    {state, [response], false}
  end

  defp handle_message(state, message) do
    response =
      Protocol.error_envelope(
        :unsupported_native_host_message,
        %{family: message.family, kind: message.kind},
        correlation_id: message.id,
        runtime_id: get_in(state, [:runtime, :runtime_id]),
        screen_id: get_in(state, [:runtime, :screen_id])
      )

    {state, [response], false}
  end

  defp normalize_windows(windows) do
    %{
      primary_id: windows[:primary_id],
      continuity: windows[:continuity] || :single_window,
      sessions:
        windows
        |> Map.get(:sessions, [])
        |> Enum.map(fn session ->
          %{
            id: session[:id],
            title: session[:title],
            role: session[:role],
            native_window?: session[:native_window?],
            window_identity: session[:window_identity],
            focus_order: session[:focus_order] || [],
            platform_target: session[:platform_target],
            owned_widget_ids: session[:owned_widget_ids] || [],
            owned_layer_ids: session[:owned_layer_ids] || []
          }
        end)
    }
  end

  defp write_message(message) do
    {:ok, frame} = Protocol.frame(message)
    IO.binwrite(:stdio, frame)
  end
end
