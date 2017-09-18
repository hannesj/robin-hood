defmodule Collector.Encoder do
  def get_message do
    entities = Enum.map(
      Core.Registry.get_all(Core.Registry),
      fn {{route, direction, start_date_time}, values} ->
        <<start_date::binary-size(10), "T", start_time::binary-size(8), _::binary>> = start_date_time

        %Collector.GtfsRt.FeedEntity{
          id: "#{route}_#{direction}_#{start_time}",
          trip_update: %Collector.GtfsRt.TripUpdate{
            trip: %Collector.GtfsRt.TripDescriptor{
              route_id: route,
              direction_id: String.to_integer(direction) - 1,
              start_time: start_time,
              start_date: String.replace(start_date, "-", ""),
              schedule_relationship: :SCHEDULED
            },
            stop_time_update: Enum.map(Core.Bucket.get(values), fn {stop_id, time} ->
              event = %Collector.GtfsRt.TripUpdate.StopTimeEvent{
                time: DateTime.to_unix(time)
              }

              %Collector.GtfsRt.TripUpdate.StopTimeUpdate{
                stop_id: stop_id,
                departure: event,
                arrival: event,
                schedule_relationship: :SCHEDULED
              }
            end)
          }
        }
      end)

    message = %Collector.GtfsRt.FeedMessage{
      header: %Collector.GtfsRt.FeedHeader{
        gtfs_realtime_version: "1.0",
        timestamp: DateTime.to_unix(DateTime.utc_now)
      },
      entity: entities
    }

    message
  end


  def encode_debug() do
    {:ok, message} = Poison.encode(get_message(), pretty: 1)
    message
  end

  def encode_protobuf() do
    Collector.GtfsRt.FeedMessage.encode(get_message())
  end
end
