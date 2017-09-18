defmodule Mqtt.Models.Event do
  @derive [Poison.Encoder]
  defstruct [
    :joreLineId,
    :joreLineDirection,
    :journeyStartTime,
    :joreStopId,
    :event,
    :scheduledDepartureTime]
end
