defmodule PubSubTest do
  use ExUnit.Case

  alias StockSimulator.PubSub

  test "adds given stocks to topics list" do
    current_topics = %{}

    {:noreply, updated_topics} = PubSub.handle_cast({:subscribe, self(), [:BRL, :USD]}, current_topics)

    assert Map.has_key?(updated_topics, :BRL)
    assert Map.has_key?(updated_topics, :USD)
  end

  test "adds observer PID to stock subscribers list" do
    current_topics = %{BRL: []}

    {:noreply, %{BRL: updated_subscribers}} = PubSub.handle_cast({:subscribe, self(), [:BRL]}, current_topics)

    assert Enum.member?(updated_subscribers, self())
  end

  test "removes observer PID from stock subscribers list" do
    current_topics = %{BRL: [self()]}

    {:noreply, %{BRL: updated_subscribers}} = PubSub.handle_cast({:unsubscribe, self()}, current_topics)

    refute Enum.member?(updated_subscribers, self())
  end
end
