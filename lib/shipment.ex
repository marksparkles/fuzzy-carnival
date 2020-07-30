defmodule Shipment do
  @moduledoc """
    Structure to contain Shipment information
  """
  defstruct [
    source_suburb: nil,
    source_suburb_postcode: nil,
    destination_suburb: nil,
    destination_suburb_postcode: nil,
    weight: nil
  ]

end
