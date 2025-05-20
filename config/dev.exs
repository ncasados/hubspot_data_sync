import Config

config :hubspot_data_sync, HubspotDataSync.Repo,
  database: "hubspot_data_sync_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :hubspot_data_sync, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"*/15 * * * *", HubspotDataSync.ConsumeContactsWorker, args: %{}}
     ]}
  ]
