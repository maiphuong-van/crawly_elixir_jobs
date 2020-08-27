use Mix.Config

config :erlang_node_discovery,
  hosts: ["127.0.0.1", "crawlyui.com"],
  node_ports: [{:ui, 0}]

ui_node = System.get_env("UI_NODE") || "ui@127.0.0.1"
ui_node = ui_node |> String.to_atom()

user_agents = [
  "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41"
]

config :crawly,
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    Crawly.Middlewares.UniqueRequest,
    Crawly.Middlewares.RobotsTxt,
    {Crawly.Middlewares.UserAgent, user_agents: user_agents}
  ],
  # fetcher: {Crawly.Fetchers.Splash, [base_url: "http://localhost:8050/render.html"]},
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:id]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :id},
    {Crawly.Pipelines.Experimental.SendToUI, ui_node: ui_node},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ]
