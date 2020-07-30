defmodule PriceTest do
  use ExUnit.Case

  @count 5;

  setup do
    price_file = Path.join([:code.priv_dir(:sendle_code_test), "prices.csv"])
    {
      :ok,
      prices: PriceList.new(price_file)
    }
  end

  test "the price module correctly reads the expected number of prices which is currently 5", %{prices: prices} do
    assert @count = PriceList.get_number_of_prices(prices)
  end

  test "the same-zone 5000 price 4.10", %{prices: prices} do
    same_zone_5000 = PriceList.get_price_by_range_max_weight(prices, "same-zone", 5000)
    assert same_zone_5000.range == "same-zone"
    assert same_zone_5000.max_weight == 5000
    assert same_zone_5000.value == 4.10
  end

  test "the range returned for same source and destination is same-zone" do
    range = PriceList.get_range("BRI", "BRI")
    assert range == "same-zone"
  end

  test "the range returned for different source and destination is different-zone" do
    range = PriceList.get_range("ADL", "BRI")
    assert range == "different-zone"
  end

  test "the currency formatter converts 4.1 into $4.10" do
    assert "$4.10" == Quote.format_currency(Decimal.from_float(4.1))
  end

  test "the currency formatter converts 0.0 into -" do
    assert "-" == Quote.format_currency(Decimal.from_float(0.0))
  end

end
