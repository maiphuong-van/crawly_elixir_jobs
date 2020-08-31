use Mix.Config

user_agents = Enum.map(1..20, &"Crawly Bot #{&1}")

config :crawly,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    CrawlyExlirJobs.MiddleWares.AmazonRequestFilter,
    {Crawly.Middlewares.UserAgent, user_agents: user_agents}
  ],
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:id]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :id},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ],
  closespider_itemcount: 100_000
