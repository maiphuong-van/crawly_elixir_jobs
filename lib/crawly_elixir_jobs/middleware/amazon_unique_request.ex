defmodule CrawlyExlirJobs.MiddleWare.AmazonUniqueRequest do
  # try to filter out request to same page on Amazon but does not entirely match existing request:
  # ie "https://www.amazon.de/s?k=Drawing&page=3&qid=1598532609&ref=sr_pg_3" and "https://www.amazon.de/s?k=Drawing&page=3&qid=1598532611&ref=sr_pg_3"

  require Logger

  def run(request, state) do
    unique_request_seen_requests = Map.get(state, :unique_request_seen_requests, [])

    case Enum.any?(unique_request_seen_requests, &match_request(&1, request)) do
      true ->
        unique_request_seen_requests = Enum.concat(unique_request_seen_requests, [request])

        new_state =
          Map.put(
            state,
            :unique_request_seen_requests,
            unique_request_seen_requests
          )

        {request, new_state}

      _ ->
        Logger.debug("Dropping request: #{request.url}, as it's already processed")

        {false, state}
    end
  end

  defp match_request(seen_request, new_request) do
    seen_request = seen_request |> String.replace(~r/&qid=(.)*&/, "&")
    new_request = new_request |> String.replace(~r/&qid=(.)*&/, "&")

    String.equivalent?(seen_request, new_request)
  end
end
