defmodule Membrane.Element.MpegTS.Demuxer.Parser do
  @moduledoc false
  # Based on:
  # * https://en.wikipedia.org/wiki/MPEG_transport_stream
  # * https://en.wikipedia.org/wiki/Packetized_elementary_stream
  # * https://en.wikipedia.org/wiki/Program-specific_information
  use Bunch

  @default_stream_state %{started_pts_payload: nil}

  def init_state, do: %{streams: %{}}

  def parse_packets(packets, state, acc \\ [])

  def parse_packets(<<packet::188-binary, rest::binary>>, state, acc) do
    case parse_packet(packet, state) do
      {{:ok, data}, state} -> parse_packets(rest, state, [data | acc])
      {_error, state} -> parse_packets(rest, state, acc)
    end
  end

  def parse_packets(<<rest::binary>>, state, acc) do
    acc
    |> Enum.reverse()
    |> Enum.group_by(fn {pid, _data} -> pid end, fn {_pid, data} -> data end)
    |> Bunch.Map.map_values(&IO.iodata_to_binary/1)
    ~> {&1, rest, state}
  end

  def parse_packet(<<packet::188-binary>>, state) do
    withl pts:
            <<
              0x47::8,
              _transport_error_indicator::1,
              payload_unit_start_indicator::1,
              _transport_priority::1,
              pid::13,
              _transport_scrambling_control::2,
              adaptation_field_control::2,
              _continuity_counter::4,
              optional_fields::bitstring
            >> <- packet,
          pid: true <- pid in 32..8196 or pid in 8198..8190,
          do: {:ok, payload} <- parse_pts_optional(optional_fields, adaptation_field_control),
          do:
            {:ok, {data, stream_state}} <-
              parse_pts_payload(
                payload,
                payload_unit_start_indicator,
                state.streams[pid] || @default_stream_state
              ) do
      {{:ok, {pid, data}}, state |> put_in([:streams, pid], stream_state)}
    else
      pts: _ -> {{:error, {:invalid_packet, :pts}}, state}
      pid: _ -> {{:error, {:unsupported_packet, :pid}}, state}
      do: error -> {error, state |> put_in([:streams, pid], @default_stream_state)}
    end
  end

  defp parse_pts_optional(payload, 0b01) do
    {:ok, payload}
  end

  defp parse_pts_optional(_adaptation_field, 0b10) do
    {:error, {:unsupported_packet, :only_adaptation_field}}
  end

  defp parse_pts_optional(optional, 0b11) do
    with <<
           adaptation_field_length::8,
           _adaptation_field::binary-size(adaptation_field_length),
           payload::bitstring
         >> <- optional do
      {:ok, payload}
    else
      _ -> {:error, {:invalid_packet, :adaptation_field}}
    end
  end

  defp parse_pts_optional(_optional, 0b00) do
    {:error, {:invalid_packet, :adaptation_field_control}}
  end

  defp parse_pts_payload(<<1::24, _::bitstring>> = payload, 0b1, stream_state) do
    with {:ok, payload} <- parse_pes_packet(payload) do
      {:ok, {payload, %{stream_state | started_pts_payload: :pes}}}
    end
  end

  defp parse_pts_payload(payload, 0b0, %{started_pts_payload: :pes} = stream_state) do
    {:ok, {payload, stream_state}}
  end

  defp parse_pts_payload(_payload, _pusi, _stream_state) do
    {:error, {:unsupported_packet, :not_pes}}
  end

  defp parse_pes_packet(packet) do
    with <<
           1::24,
           _stream_id::8,
           _packet_length::16,
           optional_fields::bitstring
         >> <- packet do
      parse_pes_optional(optional_fields)
    else
      _ -> {:error, {:invalid_packet, :pes}}
    end
  end

  defp parse_pes_optional(<<0b10::2, optional::bitstring>>) do
    with <<
           _scrambling_control::2,
           _priority::1,
           _data_alignment_indicator::1,
           _copyright::1,
           _original_or_copy::1,
           _pts_dts_indicator::2,
           _escr_flag::1,
           _es_rate_flag::1,
           _dsm_trick_mode_flag::1,
           _additional_copy_info_flag::1,
           _crc_flag::1,
           _extension_flag::1,
           pes_header_length::8,
           _optional_fields::binary-size(pes_header_length),
           data::binary
         >> <- optional do
      {:ok, data}
    else
      _ -> {:error, {:invalid_packet, :pes_optional}}
    end
  end

  defp parse_pes_optional(optional) do
    optional
  end
end