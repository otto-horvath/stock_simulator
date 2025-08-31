defmodule StockSimulator.MixProject do
  use Mix.Project

  def project do
    [
      app: :stock_simulator,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: StockSimulator]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :observer, :wx],
      mod: {StockSimulator.Application, []}
    ]
  end

  defp deps do
    []
  end
end
