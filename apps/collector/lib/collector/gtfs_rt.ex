defmodule Collector.GtfsRt do
  use Protobuf, from: Path.expand("../../proto/gtfs-realtime.proto", __DIR__)
end
