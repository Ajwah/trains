defmodule TrainsTest do
  use ExUnit.Case, async: true
  doctest Trains

  describe "Trains.distance_route/2" do
    setup [:setup_graph_context]

    test "Calculates correct distance of a route belonging to a provided graph", %{graph: graph} do
      [
        {"A-B-C", 9},
        {"A-D", 5},
        {"A-D-C", 13},
        {"A-E-B-C-D", 22}
      ]
      |> Enum.each(&calculate_all_distances_and_compare(graph, &1))
    end

    test "Returns :no_such_route in the event that provided route does not belong to the provided graph", %{graph: graph} do
      ["A-E-D", "Z-Y", "ABC"]
      |> Enum.each(&calculate_all_distances_and_compare(graph, &1))
    end

    defp calculate_all_distances_and_compare(graph, {route, correct_distance}) do
      assert Trains.distance_route(graph, route) == correct_distance
    end

    defp calculate_all_distances_and_compare(graph, route) do
      assert Trains.distance_route(graph, route) == :no_such_route
    end
  end

  describe "Trains.length_shortest_route/2" do
    setup [:setup_graph_context]
    test "Calculates shortest distance of all routes belonging to provided graph, starting from provided point a to provided point b.", %{graph: graph} do
      [
        {[starting_at: "A", ending_at: "C"], 9},
        {[starting_at: "B", ending_at: "B"], 9}
      ]
      |> Enum.each(&calculate_shortest_route_and_compare(graph, &1))
    end

    test "Returns :no_such_route in case that no route is found", %{graph: graph} do
      [
        [starting_at: "A", ending_at: "Z"],
        [starting_at: "Y", ending_at: "A"],
        [starting_at: "Z", ending_at: "Y"]
      ]
      |> Enum.each(&calculate_shortest_route_and_compare(graph, &1))
    end

    test "Returns :unknown_station_provided in case that an unknown station has been provided", %{graph: graph} do
      [
        {[starting_at: "A", ending_at: "X"], :unknown_station_provided},
        {[starting_at: "a", ending_at: "b"], :unknown_station_provided}
      ]
      |> Enum.each(&calculate_shortest_route_and_compare(graph, &1))
    end

    defp calculate_shortest_route_and_compare(graph, {specifications = [starting_at: starting_at, ending_at: ending_at], shortest_distance}) do
      assert Trains.length_shortest_route(graph, specifications) == shortest_distance
    end

    defp calculate_shortest_route_and_compare(graph, specifications) do
      assert Trains.length_shortest_route(graph, specifications) == :no_such_route
    end
  end

  describe "Trains.number_trips/2" do
    setup [:setup_graph_context]

    test "Calculates number of trips required whilst fulfilling a certain condition from provided point a to provided point b, belonging to provided graph.", %{graph: graph} do
      [
        {[starting_at: "C", ending_at: "C", maximum_stops_amount: 3], 2},
        {[starting_at: "A", ending_at: "C", exactly_stops_amount: 4], 3},
        {[starting_at: "C", ending_at: "C", max_distance: 29], 7}
      ]
      |> Enum.each(&calculate_number_trips_and_compare(graph, &1))
    end

    defp calculate_number_trips_and_compare(graph, {specifications, number_trips}) do
      assert Trains.number_trips(graph, specifications) == number_trips
    end
  end

  defp setup_graph_context(_) do
    graph = ["AB5", "BC4", "CD8", "DC8", "DE6", "AD5", "CE2", "EB3", "AE7", "YZ100"]
    {:ok, graph: Trains.Prepare.graph_to_hash(graph)}
  end
end
