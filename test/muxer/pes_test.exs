defmodule Membrane.MPEGTS.Muxer.PESTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Membrane.MPEGTS.Muxer.PES

  test "oversized video PES packets use zero packet length" do
    payload = :binary.copy(<<0>>, 0xFFFF)

    <<0x00, 0x00, 0x01, _stream_id, pes_packet_length::16, _rest::binary>> =
      PES.serialize(payload, 32, :video, 90_000, 90_000)

    assert pes_packet_length == 0
  end

  test "oversized audio PES packets raise" do
    payload = :binary.copy(<<0>>, 0xFFFF)

    assert_raise ArgumentError, ~r/only allowed for video streams/, fn ->
      PES.serialize(payload, 32, :audio, 90_000, 90_000)
    end
  end

  test "non-oversized audio PES packets keep encoded packet length" do
    payload = :binary.copy(<<0>>, 100)

    <<0x00, 0x00, 0x01, _stream_id, pes_packet_length::16, _rest::binary>> =
      PES.serialize(payload, 32, :audio, 90_000, 90_000)

    assert pes_packet_length == 113
  end
end
