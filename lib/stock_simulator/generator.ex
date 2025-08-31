defmodule StockSimulator.Generator do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :schedule_next_run}}
  end

  @impl true
  def handle_continue(:schedule_next_run, %{interval: interval} = state) do
    Process.send_after(self(), :generate_stock, interval)

    {:noreply, state}
  end

  @impl true
  def handle_info(:generate_stock, %{stocks: stocks} = state) do
    price = random_price()
    stock = Enum.random(stocks)

    GenServer.cast(StockSimulator.PubSub, {:push, %{stock: stock, price: price}})

    {:noreply, state, {:continue, :schedule_next_run}}
  end

  defp random_price(), do: Float.ceil(:rand.uniform(100000) / 100.0, 2)
end
