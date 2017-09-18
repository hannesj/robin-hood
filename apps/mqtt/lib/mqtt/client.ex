defmodule Mqtt.Client do
  require Logger
  use Exmqttc.Callback

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_connect(state) do
    Logger.debug "Connected"
    Exmqttc.subscribe(:mqtt_client_pid, "mono/v2/#")
    {:ok, state}
  end

  def handle_disconnect(state) do
    Logger.debug "Disconnected"
    {:ok, state}
  end

  def handle_publish(topic, payload, state) do
    <<_::binary-size(8), rest::binary>> = topic
    {:ok, message} = Mqtt.Parser.parse(String.split(rest, "/"), payload)

    case message do
      (%Mqtt.Models.Predictions{predictions: predictions, messageTimestamp: _timestamp}) -> Enum.map(predictions, &(update_predictions(&1)))
      (%Mqtt.Models.Events{events: events, messageTimestamp: timestamp}) -> Enum.map(events, &(update_events(&1, timestamp)))

    end
    {:ok, state}
  end

  def update_predictions(%Mqtt.Models.Prediction{joreLineId: line,
    joreLineDirection: direction,
    joreStopId: stop,
    journeyStartTime: start_time,
    predictedDepartureTime: predicted_time}) do

    {:ok, predicted_datetime, _zone} = DateTime.from_iso8601(predicted_time)

    {:ok, departure_bucket} = Core.Registry.lookup(Core.Registry, {line, direction, start_time})
    Core.Bucket.put(departure_bucket, stop, predicted_datetime)
  end

  def update_events(%Mqtt.Models.Event{joreLineId: line,
    joreLineDirection: direction,
    joreStopId: stop,
    journeyStartTime: startTime},
    timestamp) do

    {:ok, timestamp_datetime, _zone} = DateTime.from_iso8601(timestamp)

    {:ok, departure_bucket} = Core.Registry.lookup(Core.Registry, {line, direction, startTime})
    Core.Bucket.put(departure_bucket, stop, timestamp_datetime)
  end
end
