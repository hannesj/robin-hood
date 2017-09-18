defmodule Core.Bucket do
  use Agent, restart: :temporary

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> {nil, %{}} end)
  end

  @doc """
  Gets a the bucket values.
  """
  def get(bucket) do
    Agent.get(bucket, &(elem(&1, 1)))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update bucket, fn {tref, map} ->
      :timer.cancel tref
      ttl = 60 * 60 * 1000
      {:ok, tref} = :timer.exit_after(ttl, :normal)
      {tref, Map.put(map, key, value)}
    end
  end
end
