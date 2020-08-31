defmodule CrawlyExlirJobs.MiddleWares.AmazonRequestFilter do
  # try to filter out request to same page on Amazon but does not entirely match existing request:
  # ie "https://www.amazon.de/s?k=Drawing&page=3&qid=1598532609&ref=sr_pg_3" and "https://www.amazon.de/s?k=Drawing&page=3&qid=1598532611&ref=sr_pg_3"

  require Logger

  @behaviour Crawly.Pipeline

  @impl Crawly.Pipeline
  def run(request, state, _opts \\ []) do
    add_headers(request)
    |> unique_url_filter(state)
  end

  defp add_headers(request) do
    new_headers =
      Map.get(request, :headers, [])
      |> Enum.concat([{"Accept", "Application/json; Charset=utf-8"}])

    Map.put(request, :headers, new_headers)
  end

  defp unique_url_filter(request, state) do
    unique_request_seen_requests = Map.get(state, :unique_request_seen_requests, %{})

    url_key = parse_request(request.url)

    case Map.get(unique_request_seen_requests, url_key) do
      nil ->
        unique_request_seen_requests = Map.put(unique_request_seen_requests, url_key, true)

        new_state =
          Map.put(
            state,
            :unique_request_seen_requests,
            unique_request_seen_requests
          )

        {request, new_state}

      _ ->
        Logger.debug("Amazon filter dropping request: #{request.url}, as it's already processed")

        {false, state}
    end
  end

  defp parse_request(url) do
    # Getting only the base url and page number for search result pages
    parsed_url =
      Regex.named_captures(
        ~r/https:\/\/\www\.amazon\.de(.)*\/(?<url>(.)*)&page=(?<page>(.)*)&(.)*/,
        url
      )

    case parsed_url do
      %{"page" => page, "url" => base_url} ->
        {base_url, page}

      nil ->
        {url, 0}
    end
  end
end
