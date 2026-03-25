defmodule DesktopUi.Sdl3.Images do
  @moduledoc """
  SDL_image-first image resource seam for the SDL3 adapter boundary.
  """

  @spec contract() :: map()
  def contract do
    %{
      backend: :sdl_image_equivalent,
      capabilities: [:asset_decode, :surface_preparation, :raw_pixel_fallback],
      future_platform_image_allowed: true
    }
  end

  @spec validation_state() :: atom()
  def validation_state, do: :image_resource_ready

  @spec prepare(String.t(), keyword()) :: {:ok, map()} | {:error, map()}
  def prepare(source, opts \\ [])

  def prepare(source, opts) when is_binary(source) do
    {:ok,
     %{
       backend: :sdl_image_equivalent,
       source: source,
       requested_size: Keyword.get(opts, :size, :original),
       decoding: :asset_decode,
       validation_state: validation_state()
     }}
  end

  def prepare(source, _opts), do: {:error, %{reason: :invalid_image_source, source: source}}

  @spec from_pixels(binary() | [term()], keyword()) :: {:ok, map()} | {:error, map()}
  def from_pixels(pixels, opts \\ [])

  def from_pixels(pixels, opts)
      when (is_binary(pixels) and byte_size(pixels) > 0) or (is_list(pixels) and pixels != []) do
    {:ok,
     %{
       backend: :raw_pixels,
       width: Keyword.get(opts, :width),
       height: Keyword.get(opts, :height),
       pixel_count: pixel_count(pixels),
       validation_state: validation_state()
     }}
  end

  def from_pixels(pixels, _opts), do: {:error, %{reason: :invalid_pixel_buffer, pixels: pixels}}

  defp pixel_count(pixels) when is_binary(pixels), do: byte_size(pixels)
  defp pixel_count(pixels) when is_list(pixels), do: length(pixels)
end
