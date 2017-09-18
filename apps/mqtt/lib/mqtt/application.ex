defmodule Mqtt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc """
  Variation of the EMQTTC client id using the host name, user agent and random number.
  See [https://github.com/emqtt/emqttc/blob/815ebeca103025bbb5eb8e4b2f6a5f79e1236d4c/src/emqttc_protocol.erl#L125](emqttc_protocol.erl#L125)
  """
  def generate_client_id do
    {:ok, host} = :inet.gethostname()
    :rand.seed(:exsplus)
    i1 = :rand.uniform(round(:math.pow(2, 48))) - 1
    i2 = :rand.uniform(round(:math.pow(2, 32))) - 1
    [user_agent(), host, (:io_lib.format("~12.16.0b~8.16.0b", [i1, i2]) |> to_string)] |> Enum.join("_")
  end

  # UserAgent
  def version(), do: "0.0.1"
  def user_agent(), do: "Elixir/RobinHood/" <> version()

  def start(_type, _args) do
    # List all child processes to be supervised

    host = Application.get_env(:mqtt, :host)
    port = Application.get_env(:mqtt, :port)

    children = [
      # Starts a worker by calling: Mqtt.Worker.start_link(arg)
      {Task, fn -> Exmqttc.start_link(Mqtt.Client, [
        name: :mqtt_client_pid
        ], [
        {:host, host},
        {:port, port},
        {:reconnect, 1},
        {:client_id, generate_client_id()}]) end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mqtt.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
