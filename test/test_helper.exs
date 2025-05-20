Mimic.copy(Tesla)
Mimic.copy(HubspotDataSync.HubspotClient)
Mimic.copy(HubspotDataSync.HubspotRatelimit)

Ecto.Adapters.SQL.Sandbox.mode(HubspotDataSync.Repo, :manual)

ExUnit.start()
