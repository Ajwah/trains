defmodule Trains.Calculator do
  alias Trains.Calculator.Helpers

  def distance_routes(graph, routes), do: Enum.map(routes, fn route -> distance_route(graph, route) end)
  def distance_route(graph, []), do: 0
  def distance_route(graph, [_h]), do: 0
  def distance_route(graph, route = [station, next_station | t]) do
    graph
    |> Helpers.calculate_distance(station, next_station)
    |> case do
      :no_such_route -> :no_such_route
      distance_so_far -> graph
        |> distance_route([next_station | t])
        |> case do
          :no_such_route -> :no_such_route
          calculated_next_distance -> distance_so_far + calculated_next_distance
        end
    end
  end

  def number_trips(_graph, starting_at: _starting_point, ending_at: _ending_point, maximum_stops_amount: 0), do: 0
  def number_trips(graph, starting_at: starting_point, ending_at: ending_point, maximum_stops_amount: maximum_stops_amount) do
    graph
    |> Helpers.get_destinations(starting_point)
    |> Enum.reduce(0, fn destination, total_count ->
      if(destination == ending_point) do
        total_count + 1
      else
        total_count + number_trips(graph, starting_at: destination, ending_at: ending_point, maximum_stops_amount: maximum_stops_amount - 1)
      end
    end)
  end

  def number_trips(_graph, starting_at: ending_point, ending_at: ending_point, exactly_stops_amount: 0), do: 1
  def number_trips(_graph, starting_at: starting_at, ending_at: ending_point, exactly_stops_amount: 0), do: 0
  def number_trips(graph, starting_at: starting_point, ending_at: ending_point, exactly_stops_amount: exactly_stops_amount) do
    graph
    |> Helpers.get_destinations(starting_point)
    |> Enum.reduce(0, fn destination, total_count ->
      total_count + number_trips(graph, starting_at: destination, ending_at: ending_point, exactly_stops_amount: exactly_stops_amount - 1)
    end)
  end

  def length_shortest_route(_, []), do: :no_such_route
  def length_shortest_route(graph, starting_at: starting_point, ending_at: ending_point) do
    graph
    |> generate_all_routes(starting_at: starting_point, ending_at: ending_point, prefix: starting_point)
    |> Enum.filter(fn
        :no_further_destinations -> false
        e -> ~r/^#{starting_point}.+#{ending_point}$/
          |> Regex.match?(e)
    end)
    |> Trains.Prepare.routes
    |> Enum.map(fn route -> {route, distance_route(graph, route)} end)
  end

  defp generate_all_routes(graph, starting_at: starting_point, ending_at: ending_point, prefix: prefix) do
    if(Trains.Calculator.Helpers.assert_no_loop(prefix)) do
      graph
      |> Helpers.get_destinations(starting_point)
      |> Enum.reduce([], fn destination, acc ->
        if(destination == ending_point) do
          ["#{prefix}-#{destination}" | acc]
        else
          generate_all_routes(graph, starting_at: destination, ending_at: ending_point, prefix: "#{prefix}-#{destination}") ++ acc
        end
      end)
    else
      [prefix]
    end
  end

  def number_trips(graph, starting_at: starting_point, ending_at: ending_point, max_distance: max_distance) do
    if(max_distance >= 0) do
      graph
      |> Helpers.get_destinations(starting_point)
      |> Enum.reduce(0, fn destination, total_count ->
        distance = Trains.Calculator.Helpers.calculate_distance(graph, starting_point, destination)
        cond do
          (max_distance - distance >= 0) && (destination == ending_point) -> total_count + 1 + number_trips(graph, starting_at: destination, ending_at: ending_point, max_distance: max_distance - distance)
          (max_distance - distance >= 0) -> total_count + number_trips(graph, starting_at: destination, ending_at: ending_point, max_distance: max_distance - distance)
          true -> total_count
        end
      end)
    else
      0
    end
  end
end
