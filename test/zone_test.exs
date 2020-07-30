defmodule ZoneTest do
  use ExUnit.Case

  @count 10;

  setup do
    zone_file = Path.join([:code.priv_dir(:sendle_code_test), "zones.csv"])
    {
      :ok,
      zones: ZoneList.new(zone_file)
    }
  end

  test "the zone module correctly reads the expected number of zones which is currently 10", %{zones: zones} do
    assert @count = ZoneList.get_number_of_zones(zones)
  end

  test "the Brisbane zone postcode is 4000", %{zones: zones} do
    brisbane = ZoneList.get_zone_by_name(zones, "Brisbane")
    assert brisbane.suburb == "Brisbane"
    assert brisbane.postcode == "4000"
    assert brisbane.zone == "BRI"
  end
end
