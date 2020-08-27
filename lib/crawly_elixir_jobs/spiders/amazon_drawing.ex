defmodule AmazonDrawing do
  use Crawly.Spider

  # Crawl amazon result for drawing supplies

  @impl Crawly.Spider
  def base_url(), do: "https://www.amazon.de"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.amazon.de//s?k=drawing&qid=1598531843"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    urls =
      document
      |> Floki.find(".a-pagination")
      |> Floki.find(".a-normal")
      |> Floki.attribute("a", "href")

    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&build_request/1)

    [{_, _, result_blocks}] = Floki.find(document, "div.s-main-slot")

    items = Enum.map(result_blocks, &parse_result/1)

    %Crawly.ParsedItem{:items => items, :requests => requests}
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

  defp build_request(url) do
    url
    |> Crawly.Utils.build_absolute_url(base_url())
    |> Crawly.Utils.request_from_url()
  end
end