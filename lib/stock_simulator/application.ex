defmodule StockSimulator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {StockSimulator.PubSub, %{}},
      {StockSimulator.Generator, %{interval: 1000, stocks: StockSimulator.available_stocks()}},
      {DynamicSupervisor, name: ObserversSupervisor}
    ]

    opts = [strategy: :one_for_one, name: StockSimulator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
