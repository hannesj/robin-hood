defmodule Mqtt.Models.Predictions do
  @derive [Poison.Encoder]
  defstruct [:predictions, :messageTimestamp]
end
