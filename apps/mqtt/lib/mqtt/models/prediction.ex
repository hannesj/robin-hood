defmodule Mqtt.Models.Prediction do
  @derive [Poison.Encoder]
  defstruct [
    :joreLineId,
    :joreLineDirection,
    :journeyStartTime,
    :joreStopId,
    :scheduledDepartureTime,
    :predictedDepartureTime]
end
