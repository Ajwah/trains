defmodule Trains.Calculator.Helpers do
  @delim "-"
  def calculate_distance(graph, station, next_station) do
    graph
    |> Map.fetch("#{station}#{next_station}")
    |> case do
      {:ok, distance} -> distance
      :error -> :no_such_route
    end
  end

  def get_destinations(graph, station) do
    graph
    |> Map.fetch(station)
    |> case do
      {:ok, destinations} -> destinations
      :error -> [:no_further_destinations]
    end
  end

  def assert_no_loop(route) do
    all_stops =
      route
      |> String.split(@delim)

    unique_stops =
      all_stops
      |> Enum.uniq

    Enum.count(all_stops) == Enum.count(unique_stops)
  end

  def sanity_check_stations(graph, a, b) do
    all_stations =
      graph
      |> Map.fetch!("all_stations")

    MapSet.member?(all_stations, a) && MapSet.member?(all_stations, b)
  end
end
