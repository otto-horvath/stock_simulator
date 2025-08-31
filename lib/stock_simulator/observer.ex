defmodule StockSimulator.Observer do
  require Logger

  use GenServer

  import StockSimulator

  alias StockSimulator.PubSub, as: PubSub

  def subscribe(stocks) do
    DynamicSupervisor.start_child(ObserversSupervisor, {__MODULE__, stocks})
  end

  def start_link(stocks) do
    GenServer.start_link(__MODULE__, stocks, name: generate_name(stocks))
  end

  @impl true
  def init(stocks) do
    {:ok, stocks, {:continue, :subscribe}}
  end

  @impl true
  def handle_continue(:subscribe, stocks) do
    Process.flag(:trap_exit, true)

    PubSub.subscribe(self(), stocks)

    {:noreply, stocks}
  end

  @impl true
  def handle_cast({:notify, %{stock: stock, price: price}}, state) do
    Logger.info("#{process_name()}::received {#{stock}, $#{price}}")

    {:noreply, state}
  end

  @impl true
  def handle_cast(:simulate_kill, _state) do
    raise ">>> Killing #{process_name()}"
  end

  def simulate_kill(observer) do
    GenServer.cast(observer, :simulate_kill)
  end

  @impl true
  def terminate(_reason, _state) do
    PubSub.unsubscribe(self())
  end

  defp generate_name(stocks) do
    random_id = :crypto.strong_rand_bytes(16)
      |> Base.encode16()
      |> String.slice(0..3)

    stocks_list = stocks
      |> Enum.map(&Atom.to_string/1)
      |> Enum.join("_")

    :"observer.#{random_id}.#{stocks_list}"
  end
end
