defmodule Trains do
  def distance_route(graph, route) do
    stations = Trains.Prepare.route(route)
    if(Enum.count(stations) < 2) do
      :no_such_route
    else
      Trains.Calculator.distance_route(graph, stations)
    end
  end

  defdelegate number_trips(graph, specifications), to: Trains.Calculator

  # def length_shortest_route(%{}, _), do: :empty_graph
  def length_shortest_route(_, []), do: :no_stations_provided
  def length_shortest_route(graph, starting_at: starting_point, ending_at: ending_point) do
    graph
    |> Trains.Calculator.Helpers.sanity_check_stations(starting_point, ending_point)
    |> if do
      graph
      |> Trains.Calculator.length_shortest_route(starting_at: starting_point, ending_at: ending_point)
      |> Enum.reduce(:no_such_route, fn {_route, distance}, shortest_so_far ->
        select_smallest_number(shortest_so_far, distance)
      end)
    else
      :unknown_station_provided
    end
  end

  defp select_smallest_number(a, b) do
    cond do
      (a == :no_such_route) -> b
      (b == :no_such_route) -> a
      a < b -> a
      true -> b
    end
  end
end