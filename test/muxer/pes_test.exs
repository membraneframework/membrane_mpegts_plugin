defmodule Membrane.MPEGTS.Muxer.PESTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias Membrane.MPEGTS.Muxer.PES

  test "oversized PES packets use zero packet length" do
    payload = :binary.copy(<<0>>, 0xFFFF)

    <<0x00, 0x00, 0x01, _stream_id, pes_packet_length::16, _rest::binary>> =
      PES.serialize(payload, 32, 90_000, 90_000)

    assert pes_packet_length == 0
  end
end
