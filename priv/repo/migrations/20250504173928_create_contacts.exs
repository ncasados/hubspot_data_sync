defmodule HubspotDataSync.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table("contacts") do
      add :external_id, :string, null: false
      add :properties, :map
    end

    create unique_index("contacts", [:external_id])
  end
end
