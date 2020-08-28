defmodule AmazonDrawing do
  use Crawly.Spider

  # Crawl amazon result for drawing supplies
  @impl Crawly.Spider
  def override_settings() do
    user_agents = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36",
      "Mozilla/5.0 (Linux; Android 6.0.1; RedMi Note 5 Build/RB3N5C; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/68.0.3440.91 Mobile Safari/537.36",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; WOW64; Trident/6.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; Microsoft Outlook 14.0.7113; ms-office; MSOffice 14)",
      "Mozilla/5.0 (BB10; Kbd) AppleWebKit/537.35+ (KHTML, like Gecko) Version/10.3.1.2243 Mobile Safari/537.35+",
      "Mozilla/5.0 (Linux; Android 4.4.2; QMV7A Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.135 Safari/537.36",
      "Mozilla/5.0 (Linux; Android 4.4.2; en-us; SAMSUNG SM-P600 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Version/1.5 Chrome/28.0.1500.94 Safari/537.36",
      "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2231.0 Safari/537.36",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_2 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) CriOS/43.0.2357.51 Mobile/11D257 Safari/9537.53",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.94 Safari/537.36",
      "Mozilla/5.0 (Linux; U; Android 4.0.3; en-us; HTC_C715c Build/IML74K) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; WOW64; Trident/4.0; .NET4.0E; .NET4.0C; .NET CLR 3.5.30729; .NET CLR 2.0.50727; .NET CLR 3.0.30729; 360SE)"
    ]

    middlewares = [
      Crawly.Middlewares.DomainFilter,
      CrawlyExlirJobs.MiddleWare.AmazonUniqueRequest,
      {Crawly.Middlewares.UserAgent, user_agents: user_agents}
    ]

    [middlewares: middlewares]
  end

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
    IO.inspect("Parsing request: #{response.request.url}")

    {:ok, document} = Floki.parse_document(response.body)

    page_urls = Floki.find(document, ".a-pagination") |> Floki.attribute("a", "href")

    categories_urls =
      case Floki.find(document, ".a-section.octopus-pc-category-card-v2") do
        [] -> []
        urls -> Floki.attribute(urls, "a", "href")
      end

    requests =
      page_urls
      |> Enum.concat(categories_urls)
      |> Enum.uniq()
      |> Enum.map(&build_request/1)

    items =
      case Floki.find(document, "div.s-main-slot") do
        [{_, _, result_blocks}] -> result_blocks |> Enum.map(&parse_result/1)
        _ -> []
      end

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
