Geocoder.configure(
  lookup: :mapbox,
  api_key: ENV["MAPBOX_API_KEY"],
  units: :km,
  timeout: 5
)
