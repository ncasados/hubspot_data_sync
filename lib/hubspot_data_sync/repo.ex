defmodule HubspotDataSync.Repo do
  use Ecto.Repo,
    otp_app: :hubspot_data_sync,
    adapter: Ecto.Adapters.Postgres
end
