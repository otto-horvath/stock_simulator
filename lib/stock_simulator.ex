defmodule StockSimulator do
  def main(_args) do
    sample_run()

    IO.gets("Press any key to finish.")
  end

  def process_name(), do: process_name(self())

  def process_name(pid) do
    [registered_name: name] = Process.info(pid, [:registered_name])
    name
  end

  def available_stocks(), do: [:NXTT, :OPEN, :IPDN, :NVDA, :GMHS]

  def sample_run() do
    {:ok, _observer1} = StockSimulator.Observer.subscribe([:NVDA, :GMHS])
    {:ok, _observer2} = StockSimulator.Observer.subscribe([:NVDA, :NXTT, :IPDN])
    {:ok, _observer3} = available_stocks()
      |> Enum.take_random(3)
      |> StockSimulator.Observer.subscribe()
  end
end
