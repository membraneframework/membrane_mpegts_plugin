Mix.install([
  {:membrane_mpegts_plugin, path: "../"},
  :membrane_file_plugin
])

defmodule MuxingExample do
  import Membrane.ChildrenSpec
  require Membrane.RCPipeline, as: RCPipeline
  alias Membrane.RCMessage.EndOfStream
  alias Membrane.MPEGTS.Muxer

  def run() do
    spec = [
      child(:audio_source, %Membrane.File.Source{location: "../test/fixtures/bbb.aac"})
      |> child(:audio_parser, Membrane.AAC.Parser)
      |> via_in(:audio_input)
      |> child(:muxer, Muxer)
      |> child(:sink, %Membrane.File.Sink{location: "out.ts"}),
      child(:video_source, %Membrane.File.Source{location: "../test/fixtures/bbb.h264"})
      |> child(:video_parser, %Membrane.H264.Parser{
        generate_best_effort_timestamps: %{framerate: {25, 1}}
      })
      |> via_in(:video_input)
      |> get_child(:muxer)
    ]
    
    pid = RCPipeline.start_link!()
    RCPipeline.exec_actions(pid, spec: spec)
    RCPipeline.subscribe(pid, %EndOfStream{})
    RCPipeline.await_end_of_stream(pid, :sink, :input)
    RCPipeline.terminate(pid)
  end
end

MuxingExample.run()
