defmodule Collector.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_link do
    Plug.Adapters.Cowboy.http(Collector.Router, [])
  end

  get "/debug" do
    conn
    |> send_resp(200, Collector.Encoder.encode_debug)
  end


  get "/" do
    conn
    |> send_resp(200, Collector.Encoder.encode_protobuf)
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
