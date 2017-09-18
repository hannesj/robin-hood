defmodule Mqtt.Parser do
  def parse(["predictions", "stop", _stop], message) do
    Poison.decode(message, as: %Mqtt.Models.Predictions{predictions: [%Mqtt.Models.Prediction{}]})
  end

  def parse(["events", "stop", _stop], message) do
    Poison.decode(message, as: %Mqtt.Models.Events{events: [%Mqtt.Models.Event{}]})
  end
end
