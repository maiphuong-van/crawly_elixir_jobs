defmodule ElixirRadar do
  use Crawly.Spider

  @impl Crawly.Spider
  def override_settings() do
    pipelines = [
      {Crawly.Pipelines.Validate, fields: [:title, :location]},
      CrawlyElixirJobs.Pipleline.Filter,
      Crawly.Pipelines.JSONEncoder,
      {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
    ]

    [pipelines: pipelines]
  end

  @impl Crawly.Spider
  def base_url(), do: "https://elixir-radar.com"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://elixir-radar.com/jobs"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    urls =
      document
      |> Floki.find("a.pagination__button")
      |> Floki.attribute("href")

    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&build_absolute_url/1)
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    items =
      document
      |> Floki.find(".job-board-job-details")
      |> Enum.map(&create_item/1)

    %Crawly.ParsedItem{:items => items, :requests => requests}
  end

  defp build_absolute_url(url), do: URI.merge(base_url(), url) |> to_string()

  defp create_item(job) do
    title =
      job
      |> Floki.find(".job-board-job-title")
      |> parse()

    url =
      job
      |> Floki.find(".job-board-job-title")
      |> Floki.attribute("a", "href")

    location =
      job
      |> Floki.find(".job-board-job-location")
      |> parse()

    description =
      job
      |> Floki.find(".job-board-job-description")
      |> parse()

    %{title: title, location: location, description: description, url: url}
  end

  defp parse(text) do
    text
    |> Floki.text()
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end
