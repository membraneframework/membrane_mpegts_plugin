defmodule Membrane.MPEG.TS.TableTest do
  use ExUnit.Case
  alias Membrane.MPEG.TS.Support.Fixtures
  alias Membrane.MPEG.TS.Table

  describe "Table header parser" do
    test "parses valid PAT header" do
      assert {:ok, {header, data, crc}} = Table.parse(Fixtures.pat_payload())

      assert header == %Table{
               table_id: 0,
               section_syntax_indicator: true,
               section_length: 13,
               transport_stream_id: 1,
               version_number: 0,
               current_next_indicator: true,
               section_number: 0,
               last_section_number: 0
             }

      assert data == %{1 => 4096}
      assert crc == <<0x2A, 0xB1, 0x04, 0xB2>>
    end

    test "parses valid PMT header" do
      assert {:ok, {header, data, crc}} = Table.parse(Fixtures.pmt_payload())

      assert header == %Table{
               table_id: 2,
               section_syntax_indicator: true,
               section_length: 23,
               transport_stream_id: 1,
               version_number: 0,
               current_next_indicator: true,
               section_number: 0,
               last_section_number: 0
             }

      assert data == %Membrane.MPEG.TS.ProgramMapTable{
               pcr_pid: 256,
               program_info: [],
               streams: %{
                 256 => %{stream_type: :H264, stream_type_id: 27},
                 257 => %{stream_type: :MPEG1_AUDIO, stream_type_id: 3}
               }
             }
    end

    test "returns an error when data is invalid" do
      assert {:error, :malformed_header} == Table.parse(<<123, 231, 132>>)
    end
  end
end
