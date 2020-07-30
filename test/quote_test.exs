defmodule QuoteTest do
  use ExUnit.Case

  setup do
    zone_file = Path.join([:code.priv_dir(:sendle_code_test), "zones.csv"])
    price_file = Path.join([:code.priv_dir(:sendle_code_test), "prices.csv"])

    {
      :ok,
      pricing: Quote.new(zones: zone_file, prices: price_file)
    }
  end

  test "the quote for unknown source to Brisbane acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Timbuktoo", destination_suburb: "Brisbane", weight: 200}
    assert_raise ArgumentError, fn -> Quote.get_quote(pricing, shipment) end
  end

  test "the quote for Brisbane to Unknown destination acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Brisbane", destination_suburb: "Timbuktoo", weight: 200}
    assert_raise ArgumentError, fn -> Quote.get_quote(pricing, shipment) end
  end

  test "the quote for Brisbane to Brisbane acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Brisbane", destination_suburb: "Brisbane", weight: 200}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 4.1
  end

  test "the quote for Brisbane to Brisbane too heavy", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Brisbane", destination_suburb: "Brisbane", weight: 200000}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 0
  end

  test "the quote for Adelaide to Sydney acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Adelaide", destination_suburb: "Sydney", weight: 4000}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 9.5
  end

  test "the quote for Sydney to Glebe acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Sydney", destination_suburb: "Glebe", weight: 5000}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 4.1
  end

  test "the quote for Perth to Brisbane acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Perth", destination_suburb: "Brisbane", weight: 10000}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 14.9
  end

  test "the quote for Melbourne to Modbury unacceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Melbourne", destination_suburb: "Modbury", weight: 12000}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 0
  end

  test "the quote for South Perth to Brisbane acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "South Perth", destination_suburb: "Brisbane", weight: 8000}
    assert_raise ArgumentError, fn -> Quote.get_quote(pricing, shipment) end
  end

  test "the quote for Fremantle to Adelaide acceptable weight", %{pricing: pricing} do
    shipment = %Shipment{source_suburb: "Fremantle", destination_suburb: "Adelaide", weight: 500}
    quote = Quote.get_quote(pricing, shipment)
    assert quote.price.value == 4.5
  end


  test "the pricing system works", %{pricing: pricing} do
    shipments = [
      %Shipment{source_suburb: "Brisbane", source_suburb_postcode: "4000", destination_suburb: "Brisbane", destination_suburb_postcode: "4000", weight: 200},
      %Shipment{source_suburb: "Adelaide", source_suburb_postcode: "5000", destination_suburb: "Sydney", destination_suburb_postcode: "2000", weight: 4000},
      %Shipment{source_suburb: "Sydney", source_suburb_postcode: "2000", destination_suburb: "Glebe", destination_suburb_postcode: "2037", weight: 5000},
      %Shipment{source_suburb: "Perth", source_suburb_postcode: "6000", destination_suburb: "Brisbane", destination_suburb_postcode: "4000", weight: 10000},
      %Shipment{source_suburb: "Melbourne", source_suburb_postcode: "3000", destination_suburb: "Modbury", destination_suburb_postcode: "5092", weight: 12000},
      %Shipment{source_suburb: "South Perth", source_suburb_postcode: "6151", destination_suburb: "Brisbane", destination_suburb_postcode: "4000", weight: 8000},
      %Shipment{source_suburb: "Fremantle", source_suburb_postcode: "6160", destination_suburb: "Adelaide", destination_suburb_postcode: "5000", weight: 500},
    ]

    quotes = Quote.get_quotes(pricing, shipments)
    display = Quote.print_quotes(quotes)

    # For extra credit, make this layout nicer :)
    #
    expected_display = """
    Quote Report

    Brisbane, 4000 to Brisbane, 4000, 200gm: $4.10
    Adelaide, 5000 to Sydney, 2000, 4000gm: $9.50
    Sydney, 2000 to Glebe, 2037, 5000gm: $4.10
    Perth, 6000 to Brisbane, 4000, 10000gm: $14.90
    Melbourne, 3000 to Modbury, 5092, 12000gm: -
    South Perth, 6151 to Brisbane, 4000, 8000gm: -
    Fremantle, 6160 to Adelaide, 5000, 500gm: $4.50

    Total: $37.10
    """

    assert expected_display == display
  end
end
