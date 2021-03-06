defmodule Membrane.MPEG.TS.ProgramAssociationTable do
  @moduledoc false

  @type program_id_t :: 0..65_535
  @type entry :: %{
          program_number: program_id_t,
          program_map_pid: 0..8191
        }

  @entry_length 4

  # Parses Program Association Table data.
  # Each entry should be 4 bytes long. If provided data length is not divisible
  # by entry length an error shall be returned.
  @spec parse(binary) :: {:ok, map()} | {:error, :malformed_data}
  def parse(data) when rem(byte_size(data), @entry_length) == 0 do
    programs =
      for <<program_number::16, _reserved::3, pid::13 <- data>>,
        into: %{} do
        {program_number, pid}
      end

    {:ok, programs}
  end

  def parse(_) do
    {:error, :malformed_data}
  end
end
