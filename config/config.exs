use Mix.Config

config :erlang_node_discovery,
  hosts: ["127.0.0.1", "crawlyui.com"],
  node_ports: [{:ui, 0}]

ui_node = System.get_env("UI_NODE") || "ui@127.0.0.1"
ui_node = ui_node |> String.to_atom()

config :crawly,
  # fetcher: {Crawly.Fetchers.Splash, [base_url: "http://localhost:8050/render.html"]},
  pipelines: [
    {Crawly.Pipelines.Validate, fields: [:id]},
    {Crawly.Pipelines.DuplicatesFilter, item_id: :id},
    {Crawly.Pipelines.Experimental.SendToUI, ui_node: ui_node},
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ]
