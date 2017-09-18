defmodule Mqtt.Models.Events do
  @derive [Poison.Encoder]
  defstruct [:events, :messageTimestamp]
end
