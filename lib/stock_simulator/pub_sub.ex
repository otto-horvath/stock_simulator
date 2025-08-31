defmodule StockSimulator.PubSub do
  require Logger
  import StockSimulator

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_cast({:push, %{stock: stock, price: price}}, topics) do
    Logger.info("PubSub::received {#{stock}, $#{price}}")

    topics
    |> Map.get(stock, [])
    |> Enum.each(fn subscriber ->
      GenServer.cast(subscriber, {:notify, %{stock: stock, price: price}})
    end)

    {:noreply, topics}
  end

  @impl true
  def handle_cast({:subscribe, observer, stocks}, topics) do
    {:noreply, subscribe_observer_to_topics(topics, observer, stocks)}
  end

    @impl true
  def handle_cast({:unsubscribe, observer}, topics) do
    {:noreply, unsubscribe_observer_from_topics(topics, observer)}
  end

  def subscribe(observer, stocks), do: GenServer.cast(__MODULE__, {:subscribe, observer, stocks})

  def unsubscribe(observer), do: GenServer.cast(StockQueue, {:unsubscribe, observer})

  defp subscribe_observer_to_topics(topics, observer, stocks) do
    stocks
    |> Enum.reduce(topics, fn stock, subscribers ->
      Logger.info("PubSub::Subscribing {#{process_name(observer)}, #{stock}}")

      Map.update(subscribers, stock, [observer], fn subs -> [observer | subs] end)
    end)
  end

  defp unsubscribe_observer_from_topics(topics, observer) do
    topics
    |> Map.keys()
    |> Enum.reduce(topics, fn stock, subscribers ->
      Map.update!(subscribers, stock, &( List.delete(&1, observer) ))
    end)
  end
end
