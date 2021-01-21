defmodule CrawlyElixirJobs.Pipleline.Filter do
  @moduledoc """
  Custom duplicate filter. When both item title and location matchs, we need to filter them out
  """

  @behaviour Crawly.Pipeline

  require Logger

  @impl Crawly.Pipeline
  def run(item, state, _opts \\ []) do
    duplicate_key = item.title <> " " <> item.location

    duplicates_filter = Map.get(state, :duplicates_filter, %{})

    case Map.has_key?(duplicates_filter, duplicate_key) do
      false ->
        new_dups_filter = Map.put(duplicates_filter, duplicate_key, true)
        new_state = Map.put(state, :duplicates_filter, new_dups_filter)
        {item, new_state}

      true ->
        Logger.debug("Duplicates filter dropped item: #{inspect(item)}")
        {false, state}
    end
  end
end
