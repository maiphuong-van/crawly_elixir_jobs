use Mix.Config

config :crawly,
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:title, :location]},
    CrawlyElixirJobs.Pipleline.Filter,
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ]
