defmodule PriceList do
  @moduledoc """
  Contains functionality related to Prices
  """

  def new(path) do
    path
    |> read_prices
  end

  def read_prices(file) do
    file
    |> File.stream!
    |> MyParser.parse_stream
    |> Stream.map(fn
      [range, max_weight, value] ->
          %Price{range: range, max_weight: String.to_integer(max_weight), value: String.to_float(value)}
        end)
    |> Enum.to_list
  end

  def get_price_by_range_max_weight(prices, range, weight) do
    Enum.find(prices, fn(price) -> price.range == range and weight <= price.max_weight  end)
  end

  def get_number_of_prices(prices) do
    Enum.count(prices)
  end

  def get_range(source, destination) do
    if source == destination do
      "same-zone"
    else
      "different-zone"
    end
  end
end

