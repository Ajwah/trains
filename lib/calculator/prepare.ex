defmodule Trains.Prepare do
  @delim "-"
  @graph_symbols "[a-zA-Z]"

  def route(route), do: route |> String.split(@delim)
  def routes(routes), do: routes |> Enum.map(&route/1)

  def graph_to_hash(graph = [_h | _t]) do
    graph
    |> Enum.reduce(%{}, fn (e, a) ->
      ~r/(?<start>#{@graph_symbols})(?<end>#{@graph_symbols})(?<distance>\d+)/
      |> Regex.named_captures(e)
      |> graph_accumulator(a)
    end)
  end

  defp graph_accumulator(%{"distance" => distance, "end" => end_point, "start" => start_point}, acc) do
    acc
    |> Map.merge(%{"#{start_point}#{end_point}" => distance |> String.to_integer})
    |> Map.update(start_point, [end_point], fn current_list -> [end_point | current_list] end)
    |> Map.update("all_stations", MapSet.new([start_point, end_point]), fn set_of_stations -> [start_point, end_point] |> Enum.reduce(set_of_stations, &MapSet.put(&2, &1)) end)
  end
end