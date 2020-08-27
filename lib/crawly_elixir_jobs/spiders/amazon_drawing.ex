defmodule AmazonDrawing do
  use Crawly.Spider

  # Crawl amazon result for drawing supplies

  @impl Crawly.Spider
  def base_url(), do: "https://www.amazon.de"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.amazon.de/s?i=office-products&rh=n%3A192416031%2Cn%3A192417031%2Cn%3A197755031&qid=1598537871&ref=sr_pg_1"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    page_urls =
      case Floki.find(document, ".a-pagination") do
        [] -> Floki.find(document, ".pagnLink")
        urls -> Floki.find(urls, ".a-normal")
      end
      |> Floki.attribute("a", "href")

    requests =
      page_urls
      |> Enum.uniq()
      |> Enum.map(&build_request/1)

    items =
      case Floki.find(document, "div.s-main-slot") do
        [{_, _, result_blocks}] ->
          result_blocks |> Enum.map(&parse_result/1)

        _ ->
          document |> Floki.find("li.s-result-item") |> Enum.map(&parse_first_page/1)
      end

    %Crawly.ParsedItem{:items => items, :requests => []}
  end

  defp parse_result(item) do
    id = item |> Floki.attribute("data-asin") |> Floki.text()

    if String.length(id) > 0 do
      image = item |> Floki.attribute("img", "src") |> Floki.text()
      title = item |> Floki.find("h2") |> Floki.text()
      price = item |> Floki.find(".a-price-whole") |> Floki.text()

      url =
        item
        |> Floki.find(".a-link-normal")
        |> Floki.attribute("href")
        |> hd()
        |> Crawly.Utils.build_absolute_url(base_url())

      %{id: id, title: title, price: price, image: image, url: url}
    else
      %{}
    end
  end

  defp parse_first_page(item) do
    id = item |> Floki.attribute("data-asin") |> Floki.text()

    if String.length(id) > 0 do
      image = item |> Floki.attribute("img", "src") |> Floki.text()
      title = item |> Floki.find("h2") |> Floki.text()
      url = item |> Floki.find(".a-link-normal") |> Floki.attribute("href") |> hd()
      price = item |> Floki.find(".s-price") |> Floki.text()
      %{id: id, title: title, price: price, image: image, url: url}
    else
      %{}
    end
  end

  defp build_request(url) do
    url
    |> Crawly.Utils.build_absolute_url(base_url())
    |> Crawly.Utils.request_from_url()
  end
end
