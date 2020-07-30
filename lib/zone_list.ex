NimbleCSV.define(MyParser, separator: ",", escape: "\"")

defmodule ZoneList do
  @moduledoc """
  Contains functionality related to Zones
  """

  def new(path) do
    path
    |> read_zones
  end

  def read_zones(file) do
    file
    |> File.stream!
    |> MyParser.parse_stream
    |> Stream.map(fn
      [suburb, postcode, zone] ->
          %Zone{suburb: :binary.copy(suburb), postcode: :binary.copy(postcode), zone: :binary.copy(zone)}
        end)
    |> Enum.to_list
  end

  def get_zone_by_name(zones, zone_name) do
    Enum.find(zones, fn(zone) -> zone.suburb == zone_name end)
  end

  def get_number_of_zones(zones) do
    Enum.count(zones)
  end
end
