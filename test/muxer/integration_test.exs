defmodule Membrane.MPEGTS.Muxer.IntegrationTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import Membrane.Testing.Assertions
  import Membrane.ChildrenSpec

  alias Membrane.Pipeline
  alias Membrane.MPEGTS.Muxer
  alias Membrane.Testing.Pipeline

  @input_audio "test/fixtures/bbb.aac"
  @input_video "test/fixtures/bbb.h264"
  @ref_audio_and_video "test/fixtures/integration/reference_with_audio_and_video.ts"
  @ref_only_video "test/fixtures/integration/reference_only_video.ts"

  @tag :tmp_dir
  test "muxer muxes audio and video streams", ctx do
    result_path = Path.join(ctx.tmp_dir, "result.ts")

    spec = [
      child(:audio_source, %Membrane.File.Source{location: @input_audio})
      |> child(:audio_parser, Membrane.AAC.Parser)
      |> via_in(:audio_input)
      |> child(:muxer, Muxer)
      |> child(:sink, %Membrane.File.Sink{location: result_path}),
      child(:video_source, %Membrane.File.Source{location: @input_video})
      |> child(:video_parser, %Membrane.H264.Parser{
        generate_best_effort_timestamps: %{framerate: {25, 1}}
      })
      |> via_in(:video_input)
      |> get_child(:muxer)
    ]

    pid = Pipeline.start_link_supervised!()
    Pipeline.execute_actions(pid, spec: spec)

    assert_end_of_stream(pid, :sink)
    Pipeline.terminate(pid)

    assert_or_snapshot(result_path, @ref_audio_and_video)
  end

  @tag :tmp_dir
  test "muxer muxes a single video stream", ctx do
    result_path = Path.join(ctx.tmp_dir, "result.ts")

    spec = [
      child(:video_source, %Membrane.File.Source{location: @input_video})
      |> child(:video_parser, %Membrane.H264.Parser{
        generate_best_effort_timestamps: %{framerate: {30, 1}}
      })
      |> via_in(:video_input)
      |> child(:muxer, Muxer)
      |> child(:sink, %Membrane.File.Sink{location: result_path})
    ]

    pid = Pipeline.start_link_supervised!()
    Pipeline.execute_actions(pid, spec: spec)

    assert_end_of_stream(pid, :sink)
    Pipeline.terminate(pid)

    assert_or_snapshot(result_path, @ref_only_video)
  end

  defp assert_or_snapshot(result_path, reference_path) do
    if System.get_env("UPDATE_SNAPSHOTS") do
      File.cp!(result_path, reference_path)
    else
      assert File.read!(result_path) == File.read!(reference_path)
    end
  end
end
