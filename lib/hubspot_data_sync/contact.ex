defmodule HubspotDataSync.Contact do
  alias HubspotDataSync.Repo

  use Ecto.Schema

  import Ecto.Changeset

  schema "contacts" do
    field :external_id, :string
    field :properties, :map
  end

  def changeset(contact, params \\ %{}) do
    contact
    |> cast(params, [:external_id, :properties])
    |> unique_constraint([:external_id])
    |> validate_required([:external_id])
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> HubspotDataSync.Repo.insert()
  end

  def list() do
    Repo.all(__MODULE__)
  end
end
