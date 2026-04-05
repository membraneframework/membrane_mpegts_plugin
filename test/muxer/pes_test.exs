defmodule Membrane.MPEGTS.Muxer.PESTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Membrane.MPEGTS.Muxer.PES

  test "audio PES packets use the audio stream id" do
    <<0x00, 0x00, 0x01, stream_id, _length::16, _rest::binary>> =
      PES.serialize(<<1, 2, 3>>, :audio, 90_000, 90_000)

    assert stream_id == 0xC0
  end

  test "video PES packets use the video stream id" do
    <<0x00, 0x00, 0x01, stream_id, _length::16, _rest::binary>> =
      PES.serialize(<<1, 2, 3>>, :video, 90_000, 90_000)

    assert stream_id == 0xE0
  end
end
