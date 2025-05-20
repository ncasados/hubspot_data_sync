import Config

config :hubspot_data_sync, HubspotDataSync.Repo,
  database: "hubspot_data_sync_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :hubspot_data_sync, Oban, testing: :manual
