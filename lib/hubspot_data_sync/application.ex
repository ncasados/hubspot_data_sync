defmodule HubspotDataSync.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HubspotDataSync.Repo,
      HubspotDataSync.HubspotRatelimit,
      {Oban, Application.fetch_env!(:hubspot_data_sync, Oban)}
    ]

    opts = [strategy: :one_for_one, name: HubspotDataSync.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
