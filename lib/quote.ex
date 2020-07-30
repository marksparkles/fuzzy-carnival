defmodule Quote do
  @moduledoc """
  Contains functionality related to Quotes
  """

  defstruct [
    shipment: nil,
    price: nil
  ]


  defimpl String.Chars, for: Quote do
    def to_string(quote) do
      formatted_value = Quote.format_currency(Decimal.from_float(quote.price.value))
      "#{quote.shipment.source_suburb}, #{quote.shipment.source_suburb_postcode} to #{quote.shipment.destination_suburb}, #{quote.shipment.destination_suburb_postcode}, #{quote.shipment.weight}gm: #{formatted_value}"
    end
  end

  def new(opts \\ []) do
    zones_file = opts[:zones]
    prices_file = opts[:prices]

    zones = ZoneList.new(zones_file)
    prices = PriceList.new(prices_file)

    {zones, prices}
  end

  def get_quotes(pricing_model, shipments) do
    Enum.map(
      shipments,
      fn shipment ->
        try do
          get_quote(pricing_model, shipment)
        rescue
          e in ArgumentError -> IO.puts("\nAn error occurred: " <> e.message)
                                %Quote{shipment: shipment, price: %Price{range: "", max_weight: 0, value: 0.0}}
        end

      end
    )
  end

  def get_quote(pricing_model, shipment) do
    zones = elem(pricing_model, 0)
    prices = elem(pricing_model, 1)

    shipment_source_zone = ZoneList.get_zone_by_name(zones, shipment.source_suburb)
    if is_nil(shipment_source_zone) do
      raise ArgumentError, message: "unknown shipment source " <> shipment.source_suburb
    end

    destination_source_zone = ZoneList.get_zone_by_name(zones, shipment.destination_suburb)
    if is_nil(destination_source_zone) do
      raise ArgumentError, message: "unknown shipment destination " <> shipment.destination_suburb
    end

    range = PriceList.get_range(shipment_source_zone.zone, destination_source_zone.zone)
    price = PriceList.get_price_by_range_max_weight(prices, range, shipment.weight)
    if is_nil(price) do
      %Quote{shipment: shipment, price: %Price{range: range, max_weight: 0, value: 0.0}}
    else
      %Quote{shipment: shipment, price: price}
    end
  end

  def print_quotes(quotes) do
    total = Enum.map(quotes, fn(quote) -> quote.price.value end)
    |> Enum.sum
    |> Decimal.from_float

    map = Enum.map(quotes, fn(quote) -> to_string(quote) end)
          |> Enum.join("\n")

    "Quote Report\n\n" <> map <> "\n\nTotal: #{Quote.format_currency(total)}\n"
  end

  def format_currency(value) do
    if (Decimal.to_float(value) == 0.0) do
      "-"
    else
      Number.Currency.number_to_currency(value)
    end
  end
end
