defmodule Miners do
  @moduledoc "Agent that stores a list of connected peers"
  use Agent

  def start() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(miner) do
    Agent.update(__MODULE__, fn miners ->
      [miner | miners]
    end)
  end

  def remove(miner) do
    Agent.update(__MODULE__, fn miners ->
      Enum.filter(miners, fn m ->
        m != miner
      end)
    end)
  end

  def get_all do
    Agent.get(__MODULE__, fn miners ->
      miners
    end)
  end

  def remove_all do
    Agent.update(__MODULE__, fn _ ->
      []
    end)
  end
end